#!/usr/bin/env node
// Weekly newsletter generator — parses git history, builds HTML, creates Buttondown draft

import { execSync } from "node:child_process";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const BUTTONDOWN_API = "https://api.buttondown.com/v1";
const API_KEY = process.env.BUTTONDOWN_API_KEY;
const SITE_URL = "https://vancouvercommunity.org";
const CONTENT_DIR = join(process.cwd(), "content");

if (!API_KEY) {
  console.error("BUTTONDOWN_API_KEY is required");
  process.exit(1);
}

// ── Parse git log ──────────────────────────────────────────────

function getRecentChanges() {
  const log = execSync('git log --since="7 days ago" --format="%s" -- content/', {
    encoding: "utf-8",
  }).trim();

  if (!log) return { adds: [] };

  const lines = log.split("\n");
  const adds = new Map();

  for (const msg of lines) {
    const match = msg.match(/^Add (.+?) to ([a-z][\w-]+)$/);
    if (match && !adds.has(match[1])) {
      adds.set(match[1], match[2]);
    }
  }

  // Look up descriptions from content files
  const results = [];
  for (const [group, category] of adds) {
    let description = "";
    try {
      const content = readFileSync(join(CONTENT_DIR, `${category}.md`), "utf-8");
      const re = new RegExp(`^## ${group.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\n(?:[\\s\\S]*?)\\*\\*What:\\*\\* (.+?)$`, "m");
      const m = content.match(re);
      if (m) description = m[1];
    } catch {}
    results.push({ group, category, description });
  }

  return { adds: results };
}

// ── Category spotlight ─────────────────────────────────────────

function getSpotlightCategory() {
  const files = readdirSync(CONTENT_DIR)
    .filter((f) => f.endsWith(".md") && f !== "resources.md");

  // Deterministic pick based on ISO week number
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 1);
  const week = Math.ceil(((now - start) / 86400000 + start.getDay() + 1) / 7);
  const file = files[week % files.length];

  const content = readFileSync(join(CONTENT_DIR, file), "utf-8");
  const frontmatter = content.match(/^---\n([\s\S]*?)\n---/);
  if (!frontmatter) return null;

  const title = frontmatter[1].match(/title:\s*"(.+?)"/)?.[1];
  const emoji = frontmatter[1].match(/emoji:\s*"(.+?)"/)?.[1];
  const slug = file.replace(".md", "");

  // Extract first 3 community groups (skip utility sections like "Venues & Resources")
  const groups = [];
  const groupRegex = /^## (.+)\n(?:[\s\S]*?)\*\*What:\*\* (.+?)$/gm;
  let m;
  while ((m = groupRegex.exec(content)) && groups.length < 3) {
    if (/venue|resource/i.test(m[1])) continue;
    groups.push({ name: m[1], description: m[2] });
  }

  return { title, emoji, slug, groups };
}

// ── Pretty category name from slug ─────────────────────────────

function prettyCategory(slug) {
  return slug
    .replace(/-/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

// ── Anchor slug (matches Eleventy's heading ID generation) ─────

function anchorSlug(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/\s+/g, "-");
}

// ── Seasonal openers ───────────────────────────────────────────

const openers = [
  // Jan
  "New year, fresh start. If you're looking to try something new this month, here's what's been added to the directory.",
  // Feb
  "February in Vancouver — still dark early, but there's a lot going on indoors. Here's what's new on the directory.",
  // Mar
  "The cherry blossoms are coming and the city's starting to wake up. A few new groups landed on the directory this week.",
  // Apr
  "Spring is here and Vancouver's at its best. Perfect time to get out and try something new. Here's what's been added.",
  // May
  "Patios are open, the days are long, and there's more happening around the city than you'd think. Here's what's new.",
  // Jun
  "Summer's basically here. If you're looking for people to do things with, a few new groups just got added.",
  // Jul
  "Peak Vancouver summer. The city's alive right now. Here's what's new on the directory.",
  // Aug
  "Making the most of August? Here are some new groups and a corner of the directory worth exploring.",
  // Sep
  "Back to it. September's great for picking up something new. Here's what landed on the directory recently.",
  // Oct
  "Cozy season. Rain's back, which means it's the best time to find your people indoors. Here's what's new.",
  // Nov
  "Dark and rainy — peak time to find a community that gets you out of the house. Here's what's been added.",
  // Dec
  "End of year. If you're thinking about what to do more of next year, here are some new groups to check out.",
];

// ── Email HTML template ────────────────────────────────────────

function buildEmail(adds, spotlight) {
  let sections = "";

  // New additions
  if (adds.length > 0) {
    sections += `## Just added\n\n`;
    for (const a of adds) {
      const url = `${SITE_URL}/${a.category}#${anchorSlug(a.group)}`;
      sections += `**[${a.group}](${url})**`;
      if (a.description) sections += `\n${a.description}`;
      sections += `\n*${prettyCategory(a.category)}*\n\n`;
    }
  }

  // Spotlight (always included)
  if (spotlight && spotlight.groups.length > 0) {
    sections += `## ${spotlight.emoji} ${spotlight.title}\n\n`;
    sections += `If you haven't explored this part of the directory yet — here are a few good ones.\n\n`;
    for (const g of spotlight.groups) {
      const url = `${SITE_URL}/${spotlight.slug}#${anchorSlug(g.name)}`;
      sections += `**[${g.name}](${url})**\n${g.description}\n\n`;
    }
    sections += `[All ${spotlight.title} →](${SITE_URL}/${spotlight.slug})\n\n`;
  }

  return buildBody(sections);
}

function buildBody(sections) {
  const opener = openers[new Date().getMonth()];
  return `${opener}

${sections}

---

[Browse the directory](${SITE_URL})`;
}

// ── Main ───────────────────────────────────────────────────────

const changes = getRecentChanges();
const spotlight = getSpotlightCategory();

const datePart = new Date().toLocaleDateString("en-CA", { month: "short", day: "numeric" });

let subject;
if (changes.adds.length > 0) {
  console.log(`${changes.adds.length} new groups this week + spotlight: ${spotlight?.emoji} ${spotlight?.title}`);
  subject = `${changes.adds.length} new group${changes.adds.length > 1 ? "s" : ""} + ${spotlight?.emoji} ${spotlight?.title}`;
} else {
  console.log(`No new groups — spotlight only: ${spotlight?.emoji} ${spotlight?.title}`);
  subject = `${spotlight?.emoji} ${spotlight?.title} — groups you might not know about`;
}

const html = buildEmail(changes.adds, spotlight);

// Create draft in Buttondown
const res = await fetch(`${BUTTONDOWN_API}/emails`, {
  method: "POST",
  headers: {
    Authorization: `Token ${API_KEY}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    subject,
    body: html,
    status: "draft",
  }),
});

if (!res.ok) {
  const err = await res.text();
  console.error(`Buttondown API error (${res.status}):`, err);
  process.exit(1);
}

const draft = await res.json();
console.log(`Draft created: ${draft.id}`);
console.log("Done!");
