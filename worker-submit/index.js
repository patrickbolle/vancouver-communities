// Cloudflare Worker for community submissions -> GitHub Issues

const GITHUB_REPO = "patrickbolle/vancouver-communities";

export default {
  async fetch(request, env) {
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
      "Content-Type": "application/json"
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    if (request.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: corsHeaders
      });
    }

    try {
      const data = await request.json();
      
      // Validate required fields
      if (!data.name || !data.category || !data.description) {
        return new Response(JSON.stringify({ 
          error: "Missing required fields: name, category, description" 
        }), {
          status: 400,
          headers: corsHeaders
        });
      }

      // Build issue body
      const issueBody = `## Submitted Group

**Name:** ${data.name}
**Category:** ${data.category}

**Description:** 
${data.description}

**Vibe/Atmosphere:** 
${data.vibe || "Not specified"}

**Website/Link:** 
${data.link || "Not provided"}

**Location:** 
${data.location || "Not specified"}

**Additional Info:** 
${data.additional || "None"}

---
*Submitted via vancouvercommunity.org*
`;

      // Create GitHub issue
      const response = await fetch(
        `https://api.github.com/repos/${GITHUB_REPO}/issues`,
        {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${env.GITHUB_TOKEN}`,
            "Accept": "application/vnd.github+json",
            "User-Agent": "Vancouver-Community-Bot",
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            title: `New Group: ${data.name}`,
            body: issueBody,
            labels: ["submission", data.category.toLowerCase().replace(/[^a-z0-9]/g, '-')]
          })
        }
      );

      if (!response.ok) {
        const error = await response.text();
        console.error("GitHub API error:", error);
        return new Response(JSON.stringify({ 
          error: "Failed to create issue",
          details: error
        }), {
          status: 500,
          headers: corsHeaders
        });
      }

      const issue = await response.json();

      return new Response(JSON.stringify({ 
        success: true,
        message: "Thank you! Your submission has been received.",
        issueUrl: issue.html_url
      }), {
        headers: corsHeaders
      });

    } catch (error) {
      return new Response(JSON.stringify({ 
        error: "Server error",
        details: error.message
      }), {
        status: 500,
        headers: corsHeaders
      });
    }
  }
};
