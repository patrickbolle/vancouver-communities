// Cloudflare Worker for community submissions & edits -> GitHub Pull Requests

const GITHUB_REPO = "patrickbolle/vancouver-communities";
const DEFAULT_BRANCH = "main";

// Map form categories to file names
const CATEGORY_FILES = {
  "dinner-supper-clubs": "dinner-supper-clubs.md",
  "social-friend-clubs": "social-friend-clubs.md",
  "run-clubs": "run-clubs.md",
  "board-games": "board-games.md",
  "creative-art": "creative-art.md",
  "photography": "photography.md",
  "film-cinema": "film-cinema.md",
  "writing": "writing.md",
  "language-exchange": "language-exchange.md",
  "hiking-outdoors": "hiking-outdoors.md",
  "cycling": "cycling.md",
  "dance": "dance.md",
  "improv-comedy": "improv-comedy.md",
  "music-open-mic": "music-open-mic.md",
  "climbing": "climbing.md",
  "pickleball": "pickleball.md",
  "pottery-ceramics": "pottery-ceramics.md",
  "yoga-wellness": "yoga-wellness.md",
  "sauna-cold-plunge": "sauna-cold-plunge.md",
  "mindfulness-meditation": "mindfulness-meditation.md",
  "mens-groups": "mens-groups.md",
  "maker-spaces": "maker-spaces.md",
  "philosophy-intellectual": "philosophy-intellectual.md",
  "book-clubs": "book-clubs.md",
  "tech-startup": "tech-startup.md",
  "coworking": "coworking.md",
  "volunteer": "volunteer.md",
  "vinyl-listening-bars": "vinyl-listening-bars.md",
  "chess": "chess.md",
  "underground-dj": "underground-dj.md",
  "poetry-spoken-word": "poetry-spoken-word.md",
  "tarot-astrology": "tarot-astrology.md",
  "flea-markets-vintage": "flea-markets-vintage.md",
  "pub-trivia": "pub-trivia.md",
  "zine-risograph": "zine-risograph.md",
  "astronomy-stargazing": "astronomy-stargazing.md",
  "foraging-nature": "foraging-nature.md",
  "birdwatching": "birdwatching.md",
  "karaoke": "karaoke.md"
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Content-Type": "application/json"
};

async function githubApi(endpoint, env, options = {}) {
  const response = await fetch(`https://api.github.com${endpoint}`, {
    ...options,
    headers: {
      "Authorization": `Bearer ${env.GITHUB_TOKEN}`,
      "Accept": "application/vnd.github+json",
      "User-Agent": "Vancouver-Community-Bot",
      "Content-Type": "application/json",
      ...options.headers
    }
  });
  
  if (!response.ok) {
    const error = await response.text();
    throw new Error(`GitHub API error: ${response.status} - ${error}`);
  }
  
  return response.json();
}

function encodeBase64(str) {
  const encoder = new TextEncoder();
  const bytes = encoder.encode(str);
  return btoa(String.fromCharCode(...bytes));
}

function decodeBase64(base64) {
  const bytes = Uint8Array.from(atob(base64.replace(/\n/g, '')), c => c.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

function formatSubmissionEntry(data) {
  let entry = `\n## ${data.name}\n`;
  entry += `- **What:** ${data.description}\n`;
  
  if (data.vibe) {
    entry += `- **Vibe:** ${data.vibe}\n`;
  }
  if (data.location) {
    entry += `- **Where:** ${data.location}\n`;
  }
  if (data.link) {
    entry += `- **Find it:** [${data.link.replace(/^https?:\/\//, '')}](${data.link})\n`;
  }
  if (data.additional) {
    entry += `- **Notes:** ${data.additional}\n`;
  }
  
  return entry;
}

// GET /content/:category - Fetch current content for editing
async function handleGetContent(category, env) {
  const categoryKey = category.toLowerCase().replace(/[^a-z0-9-]/g, '-');
  const fileName = CATEGORY_FILES[categoryKey];
  
  if (!fileName) {
    return new Response(JSON.stringify({ 
      error: `Unknown category: ${category}` 
    }), { status: 400, headers: corsHeaders });
  }

  try {
    const fileData = await githubApi(
      `/repos/${GITHUB_REPO}/contents/${fileName}?ref=${DEFAULT_BRANCH}`,
      env
    );
    
    const content = decodeBase64(fileData.content);
    
    return new Response(JSON.stringify({ 
      success: true,
      category: categoryKey,
      fileName,
      content,
      sha: fileData.sha
    }), { headers: corsHeaders });
  } catch (e) {
    return new Response(JSON.stringify({ 
      error: "File not found",
      details: e.message
    }), { status: 404, headers: corsHeaders });
  }
}

// POST /submit - Add new entry
async function handleSubmit(data, env) {
  if (!data.name || !data.category || !data.description) {
    return new Response(JSON.stringify({ 
      error: "Missing required fields: name, category, description" 
    }), { status: 400, headers: corsHeaders });
  }

  const categoryKey = data.category.toLowerCase().replace(/[^a-z0-9-]/g, '-');
  const fileName = CATEGORY_FILES[categoryKey];
  
  if (!fileName) {
    return new Response(JSON.stringify({ 
      error: `Unknown category: ${data.category}` 
    }), { status: 400, headers: corsHeaders });
  }

  const timestamp = Date.now();
  const safeName = data.name.toLowerCase().replace(/[^a-z0-9]/g, '-').slice(0, 30);
  const branchName = `submission/${safeName}-${timestamp}`;

  // Get base branch SHA
  const refData = await githubApi(
    `/repos/${GITHUB_REPO}/git/refs/heads/${DEFAULT_BRANCH}`,
    env
  );
  const baseSha = refData.object.sha;

  // Get current file content
  let currentContent = "";
  let fileSha = null;
  
  try {
    const fileData = await githubApi(
      `/repos/${GITHUB_REPO}/contents/${fileName}?ref=${DEFAULT_BRANCH}`,
      env
    );
    currentContent = decodeBase64(fileData.content);
    fileSha = fileData.sha;
  } catch (e) {
    // File doesn't exist
  }

  // Create branch
  await githubApi(`/repos/${GITHUB_REPO}/git/refs`, env, {
    method: "POST",
    body: JSON.stringify({ ref: `refs/heads/${branchName}`, sha: baseSha })
  });

  // Append new entry
  const newEntry = formatSubmissionEntry(data);
  const updatedContent = currentContent.trimEnd() + "\n" + newEntry;

  // Commit file
  await githubApi(`/repos/${GITHUB_REPO}/contents/${fileName}`, env, {
    method: "PUT",
    body: JSON.stringify({
      message: `Add ${data.name} to ${categoryKey}`,
      content: encodeBase64(updatedContent),
      branch: branchName,
      ...(fileSha && { sha: fileSha })
    })
  });

  // Create PR
  const prBody = `## New Community Submission

**Name:** ${data.name}
**Category:** ${data.category}

**Description:** 
${data.description}

${data.vibe ? `**Vibe/Atmosphere:** ${data.vibe}` : ''}
${data.link ? `**Website/Link:** ${data.link}` : ''}
${data.location ? `**Location:** ${data.location}` : ''}
${data.additional ? `**Additional Info:** ${data.additional}` : ''}

---
*Submitted via vancouvercommunity.org*
`;

  const pr = await githubApi(`/repos/${GITHUB_REPO}/pulls`, env, {
    method: "POST",
    body: JSON.stringify({
      title: `Add ${data.name} to ${data.category}`,
      body: prBody,
      head: branchName,
      base: DEFAULT_BRANCH
    })
  });

  return new Response(JSON.stringify({ 
    success: true,
    message: "Thank you! Your submission has been received and is pending review.",
    prUrl: pr.html_url
  }), { headers: corsHeaders });
}

// POST /edit - Suggest edit to existing file
async function handleEdit(data, env) {
  if (!data.category || !data.content) {
    return new Response(JSON.stringify({ 
      error: "Missing required fields: category, content" 
    }), { status: 400, headers: corsHeaders });
  }

  const categoryKey = data.category.toLowerCase().replace(/[^a-z0-9-]/g, '-');
  const fileName = CATEGORY_FILES[categoryKey];
  
  if (!fileName) {
    return new Response(JSON.stringify({ 
      error: `Unknown category: ${data.category}` 
    }), { status: 400, headers: corsHeaders });
  }

  const timestamp = Date.now();
  const branchName = `edit/${categoryKey}-${timestamp}`;
  const editSummary = data.summary || "Suggested edits";

  // Get base branch SHA
  const refData = await githubApi(
    `/repos/${GITHUB_REPO}/git/refs/heads/${DEFAULT_BRANCH}`,
    env
  );
  const baseSha = refData.object.sha;

  // Get current file SHA (required for update)
  let fileSha = null;
  try {
    const fileData = await githubApi(
      `/repos/${GITHUB_REPO}/contents/${fileName}?ref=${DEFAULT_BRANCH}`,
      env
    );
    fileSha = fileData.sha;
  } catch (e) {
    return new Response(JSON.stringify({ 
      error: "File not found" 
    }), { status: 404, headers: corsHeaders });
  }

  // Create branch
  await githubApi(`/repos/${GITHUB_REPO}/git/refs`, env, {
    method: "POST",
    body: JSON.stringify({ ref: `refs/heads/${branchName}`, sha: baseSha })
  });

  // Commit edited file
  await githubApi(`/repos/${GITHUB_REPO}/contents/${fileName}`, env, {
    method: "PUT",
    body: JSON.stringify({
      message: `Edit ${categoryKey}: ${editSummary}`,
      content: encodeBase64(data.content),
      branch: branchName,
      sha: fileSha
    })
  });

  // Create PR
  const prBody = `## Suggested Edit

**Category:** ${data.category}
**Summary:** ${editSummary}

${data.reason ? `**Reason for edit:**\n${data.reason}` : ''}

---
*Submitted via vancouvercommunity.org*
`;

  const pr = await githubApi(`/repos/${GITHUB_REPO}/pulls`, env, {
    method: "POST",
    body: JSON.stringify({
      title: `Edit: ${editSummary}`,
      body: prBody,
      head: branchName,
      base: DEFAULT_BRANCH
    })
  });

  return new Response(JSON.stringify({ 
    success: true,
    message: "Thank you! Your suggested edit has been submitted for review.",
    prUrl: pr.html_url
  }), { headers: corsHeaders });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const path = url.pathname;

    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // GET /content/:category - Fetch content for editing
      if (request.method === "GET" && path.startsWith("/content/")) {
        const category = path.replace("/content/", "");
        return await handleGetContent(category, env);
      }

      // POST routes
      if (request.method === "POST") {
        const data = await request.json();

        // POST /submit - Add new entry
        if (path === "/submit" || path === "/") {
          return await handleSubmit(data, env);
        }

        // POST /edit - Suggest edit
        if (path === "/edit") {
          return await handleEdit(data, env);
        }
      }

      // 404 for unknown routes
      return new Response(JSON.stringify({ 
        error: "Not found",
        routes: {
          "GET /content/:category": "Fetch current content",
          "POST /submit": "Submit new entry",
          "POST /edit": "Suggest edit to existing content"
        }
      }), { status: 404, headers: corsHeaders });

    } catch (error) {
      console.error("Error:", error);
      return new Response(JSON.stringify({ 
        error: "Server error",
        details: error.message
      }), { status: 500, headers: corsHeaders });
    }
  }
};
