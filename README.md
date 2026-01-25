# Vancouver Community Directory

A comprehensive guide to groups, clubs, meetups, and events for connection and community in Vancouver, BC.

**Live site:** https://vancouvercommunity.org

## Architecture

```
├── *.md                    # Source content (markdown files per category)
├── build.sh               # Static site generator
├── site/                  # Generated static site (deployed to Cloudflare)
├── worker/                # Stats worker (Umami analytics proxy)
└── worker-submit/         # Submission & edit API worker
```

## How It Works

### Static Site Generation

The site is built from markdown files using `build.sh`:

```bash
./build.sh
```

This generates a complete static site in `site/` with:
- Individual pages for each category
- Full sidebar navigation on every page
- SEO metadata, sitemap, RSS feed
- Mobile-responsive design

### Cloudflare Workers

Two workers power the dynamic features:

#### 1. Main Site Worker (`wrangler.jsonc`)
- Serves the static site from `site/` directory
- Deployed to: `vancouver-communities.recipekit.workers.dev`

#### 2. Submit/Edit API Worker (`worker-submit/`)
- Handles community submissions and edit suggestions
- Creates GitHub Pull Requests for review
- Deployed to: `vancouver-community-submit.recipekit.workers.dev`

**API Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/content/:category` | Fetch current markdown content for a category |
| `POST` | `/submit` | Submit a new community/group (creates PR) |
| `POST` | `/edit` | Suggest edits to existing content (creates PR) |

**Submit payload:**
```json
{
  "name": "Group Name",
  "category": "run-clubs",
  "description": "What the group does",
  "vibe": "Optional atmosphere description",
  "link": "https://example.com",
  "location": "Optional location"
}
```

**Edit payload:**
```json
{
  "category": "run-clubs",
  "content": "Full updated markdown content",
  "summary": "Brief description of changes",
  "reason": "Optional explanation"
}
```

### GitHub Integration

All submissions and edits create Pull Requests instead of issues, allowing:
- One-click merge for approved content
- Easy editing before merge
- Full change history
- No manual copy-paste from issues

## Deployment

### Prerequisites

- [Cloudflare account](https://dash.cloudflare.com)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)
- GitHub personal access token with `repo` scope

### Deploy Static Site

```bash
# Set credentials
export CLOUDFLARE_API_TOKEN="your-token"
export CLOUDFLARE_ACCOUNT_ID="your-account-id"

# Build and deploy
./build.sh
npx wrangler deploy
```

### Deploy Submit Worker

```bash
cd worker-submit

# Set the GitHub token as a secret (one-time)
npx wrangler secret put GITHUB_TOKEN

# Deploy
npx wrangler deploy
```

### Environment Variables

The submit worker requires:
- `GITHUB_TOKEN` — GitHub PAT with repo write access (set via `wrangler secret`)

## Content Format

Each category is a markdown file following this format:

```markdown
# 🏃 Category Name

## Group Name
- **What:** Description of what the group does
- **Vibe:** Atmosphere, who it's for
- **Where:** Location (if applicable)
- **Find it:** [website.com](https://website.com)

## Another Group
...

---

## Venues & Resources

## Venue Name
- **What:** Description
- **Find it:** [link](url)
```

## Adding New Categories

1. Create `new-category.md` with content
2. Add to `CATEGORY_FILES` in `worker-submit/index.js`
3. Add to arrays in `build.sh`:
   - `titles`
   - `descriptions`
   - `emojis`
   - `categories_ordered`
4. Rebuild and redeploy both the site and worker

## Local Development

```bash
# Build site locally
./build.sh

# Serve locally (requires any static server)
cd site && python -m http.server 8000

# Test worker locally
cd worker-submit && npx wrangler dev
```

## License

Content is community-contributed. Code is MIT.

---

Created by [Patrick Bolle](https://bolle.co) for the Vancouver community.
