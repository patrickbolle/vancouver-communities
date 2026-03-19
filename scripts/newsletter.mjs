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

// ── Email HTML template ────────────────────────────────────────

function buildEmail(adds, spotlight) {
  let sections = "";

  // New additions
  if (adds.length > 0) {
    const items = adds
      .map(
        (a) =>
          `<tr>
            <td style="padding:14px 0;border-bottom:1px solid #E8E3DC;">
              <a href="${SITE_URL}/${a.category}#${anchorSlug(a.group)}" style="color:#2C2925;text-decoration:none;font-family:Georgia,serif;font-size:17px;">${a.group}</a>
              ${a.description ? `<br><span style="color:#524D48;font-size:14px;line-height:1.5;">${a.description}</span>` : ""}
              <br><span style="color:#706B65;font-size:13px;">${prettyCategory(a.category)}</span>
            </td>
          </tr>`
      )
      .join("");
    sections += `
      <h2 style="font-family:Georgia,serif;color:#2C2925;font-size:18px;margin:24px 0 8px;font-weight:normal;">Just added</h2>
      <p style="color:#706B65;margin:0 0 12px;font-size:14px;">New to the directory this week.</p>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0">${items}</table>`;
  }

  // Spotlight (always included)
  if (spotlight && spotlight.groups.length > 0) {
    const items = spotlight.groups
      .map(
        (g) =>
          `<tr>
            <td style="padding:14px 0;border-bottom:1px solid #E8E3DC;">
              <a href="${SITE_URL}/${spotlight.slug}#${anchorSlug(g.name)}" style="color:#2C2925;text-decoration:none;font-family:Georgia,serif;font-size:16px;">${g.name}</a>
              <br><span style="color:#524D48;font-size:14px;line-height:1.5;">${g.description}</span>
            </td>
          </tr>`
      )
      .join("");

    sections += `
      <h2 style="font-family:Georgia,serif;color:#2C2925;font-size:18px;margin:32px 0 8px;font-weight:normal;">${spotlight.emoji} ${spotlight.title}</h2>
      <p style="color:#706B65;margin:0 0 12px;font-size:14px;">In case you missed it — a few groups worth knowing about.</p>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0">${items}</table>
      <p style="margin-top:16px;">
        <a href="${SITE_URL}/${spotlight.slug}" style="color:#A85A46;font-size:14px;">All ${spotlight.title} &rarr;</a>
      </p>`;
  }

  return buildBody(sections);
}

function buildBody(sections) {
  return `<p style="margin:0 0 20px;color:#2C2925;font-family:Georgia,serif;font-size:15px;line-height:1.7;">The directory got a few updates this week. Here's what's new and something you might not have seen yet.</p>
${sections}
<hr style="border:none;border-top:1px solid #E8E3DC;margin:28px 0;">
<p style="text-align:center;margin:0;">
  <a href="${SITE_URL}" style="display:inline-block;background-color:#A85A46;color:#FFFFFF;padding:12px 28px;border-radius:6px;text-decoration:none;font-weight:bold;font-family:Georgia,serif;">Browse the directory</a>
</p>`;
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
