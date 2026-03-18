# Vancouver Community Directory

A guide to finding **real community** in Vancouver, BC — not just things to do, but people to belong with.

🌐 **Website:** [vancouvercommunity.org](https://vancouvercommunity.org)

---

## About

40+ categories of local groups, clubs, and meetups — from run clubs to philosophy salons to flea markets. Content lives in markdown files and gets built into a static site with [Eleventy](https://www.11ty.dev/).

## Contributing

**Add a community:** [Submit here](https://vancouvercommunity.org/submit/) or open a PR. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

To add a new category, create a `.md` file with frontmatter:

```yaml
---
layout: category
tags: category
title: "Yoga & Wellness"
description: "Free yoga and wellness events in Vancouver."
emoji: "🧘"
group: mind-body
order: 1
---
```

## Development

```bash
npm run dev    # Dev server with hot reload at localhost:8080
npm run build  # Production build
```

### File Structure

```
├── *.md                    # Category content files (edit these!)
├── eleventy.config.js      # Build configuration
├── _includes/              # Nunjucks layout templates
├── _data/                  # Shared data (site config, groups)
├── src/
│   ├── style.css           # External stylesheet
│   └── main.js             # Shared JavaScript
├── static/                 # Static assets (favicon, etc.)
├── submit.njk              # Submission form page
└── site/                   # Generated output (deploy directory)
```

### Rules

1. **Only edit `.md` files** — never manually edit HTML in `site/`
2. **External CSS only** — use `src/style.css`, never inline `<style>` blocks
3. **Group definitions** live in `_data/groups.json`

### Infrastructure

- **Build:** Eleventy (11ty)
- **Deploy:** Cloudflare Pages from `site/`
- **Analytics:** Umami
- **Submit API:** Cloudflare Worker ([source](site/_build/worker-submit/index.js))
- **Stats API:** Cloudflare Worker

---

Created by [Patrick Bollenbach](https://bollenbach.ca)
