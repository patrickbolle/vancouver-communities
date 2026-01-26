#!/bin/bash
# Build script: converts markdown files to HTML with proper structure for style.css

set -e

SITE_DIR="../"
SOURCE_DIR="../../"
SITE_URL="https://vancouvercommunity.org"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_DATE_HUMAN=$(date -u +"%B %Y")

# Category metadata
declare -A titles=(
  ["dinner-supper-clubs"]="Dinner & Supper Clubs"
  ["social-friend-clubs"]="Social & Friend Clubs"
  ["run-clubs"]="Run Clubs"
  ["board-games"]="Board Games"
  ["creative-art"]="Creative & Art"
  ["photography"]="Photography"
  ["film-cinema"]="Film & Cinema"
  ["writing"]="Writing"
  ["language-exchange"]="Language Exchange"
  ["hiking-outdoors"]="Hiking & Outdoors"
  ["cycling"]="Cycling"
  ["dance"]="Dance"
  ["improv-comedy"]="Improv & Comedy"
  ["music-open-mic"]="Music & Open Mic"
  ["climbing"]="Climbing"
  ["pickleball"]="Pickleball"
  ["pottery-ceramics"]="Pottery & Ceramics"
  ["yoga-wellness"]="Yoga & Wellness"
  ["sauna-cold-plunge"]="Sauna & Cold Plunge"
  ["mindfulness-meditation"]="Mindfulness & Meditation"
  ["mens-groups"]="Men's Groups"
  ["maker-spaces"]="Maker Spaces"
  ["philosophy-intellectual"]="Philosophy & Intellectual"
  ["book-clubs"]="Book Clubs"
  ["tech-startup"]="Tech & Startup"
  ["coworking"]="Coworking"
  ["volunteer"]="Volunteer"
  ["vinyl-listening-bars"]="Vinyl & Listening Bars"
  ["chess"]="Chess"
  ["underground-dj"]="Underground DJ"
  ["poetry-spoken-word"]="Poetry & Spoken Word"
  ["tarot-astrology"]="Tarot & Astrology"
  ["pub-trivia"]="Pub Trivia"
  ["zine-risograph"]="Zine & Risograph"
  ["astronomy-stargazing"]="Astronomy & Stargazing"
  ["foraging-nature"]="Foraging & Nature"
  ["birdwatching"]="Birdwatching"
  ["karaoke"]="Karaoke"
  ["resources"]="Resources"
)

declare -A descriptions=(
  ["dinner-supper-clubs"]="Find dinner clubs and supper clubs in Vancouver. Meet new people over curated meals and social dining."
  ["social-friend-clubs"]="Vancouver social clubs and friend-making groups. Connect through organized meetups and community events."
  ["run-clubs"]="Vancouver running clubs and social runs. Find free group runs and running communities for all levels."
  ["board-games"]="Board game cafes and game nights in Vancouver. Weekly meetups, gaming cafes, and tabletop communities."
  ["creative-art"]="Vancouver art collectives and creative communities. Studios, workshops, and groups for artists."
  ["photography"]="Vancouver photography clubs and photo walks. Community shoots and photography meetups."
  ["film-cinema"]="Vancouver film clubs and cinema events. Independent screenings and film societies."
  ["writing"]="Vancouver writing groups and workshops. Critique circles and literary communities."
  ["language-exchange"]="Language exchange meetups in Vancouver. Practice languages with native speakers."
  ["hiking-outdoors"]="Vancouver hiking groups and outdoor clubs. Find trail buddies and adventure communities."
  ["cycling"]="Vancouver cycling clubs and group rides. Social rides and cycling communities."
  ["dance"]="Dance classes and social dancing in Vancouver. Salsa, bachata, swing, and more."
  ["improv-comedy"]="Vancouver improv classes and comedy shows. Learn improv and join funny communities."
  ["music-open-mic"]="Open mics and jam sessions in Vancouver. Find stages and musicians to collaborate with."
  ["climbing"]="Vancouver climbing gyms and communities. Find climbing partners and bouldering meetups."
  ["pickleball"]="Pickleball courts and clubs in Vancouver. Drop-in games and leagues."
  ["pottery-ceramics"]="Pottery studios and ceramics classes in Vancouver. Wheel throwing and clay communities."
  ["yoga-wellness"]="Free yoga and wellness events in Vancouver. Community classes and outdoor yoga."
  ["sauna-cold-plunge"]="Sauna clubs and cold plunge spots in Vancouver. Contrast therapy and recovery communities."
  ["mindfulness-meditation"]="Meditation groups in Vancouver. Sitting groups and mindfulness meetups."
  ["mens-groups"]="Men's circles and support groups in Vancouver. Brotherhood and personal growth."
  ["maker-spaces"]="Vancouver maker spaces and workshops. Access tools and join the maker community."
  ["philosophy-intellectual"]="Philosophy meetups and discussion groups in Vancouver. Deep conversations."
  ["book-clubs"]="Vancouver book clubs and reading groups. Find your literary community."
  ["tech-startup"]="Vancouver tech meetups and startup community. Founders and developers connecting."
  ["coworking"]="Coworking spaces in Vancouver. Find your workspace community."
  ["volunteer"]="Volunteer opportunities in Vancouver. Give back through community service."
  ["vinyl-listening-bars"]="Vinyl bars and listening rooms in Vancouver. Record shops and audiophile community."
  ["chess"]="Chess clubs and cafe meetups in Vancouver. Find games and tournaments."
  ["underground-dj"]="Underground parties and DJ events in Vancouver. Warehouse raves and electronic music."
  ["poetry-spoken-word"]="Poetry slams and spoken word in Vancouver. Open mics and poetry nights."
  ["tarot-astrology"]="Tarot and astrology communities in Vancouver. Spiritual groups and readings."
  ["pub-trivia"]="Pub trivia nights in Vancouver. Test your knowledge and find your team."
  ["zine-risograph"]="Zine making and risograph printing in Vancouver. DIY publishing community."
  ["astronomy-stargazing"]="Astronomy clubs and stargazing in Vancouver. Star parties and telescope nights."
  ["foraging-nature"]="Foraging tours and nature walks in Vancouver. Learn wild foods."
  ["birdwatching"]="Birdwatching groups in Vancouver. Birding walks and nature community."
  ["karaoke"]="Karaoke bars and nights in Vancouver. Sing your heart out."
  ["resources"]="Vancouver community resources and directories."
)

declare -A emojis=(
  ["dinner-supper-clubs"]="🍽️"
  ["social-friend-clubs"]="🤝"
  ["run-clubs"]="🏃"
  ["board-games"]="🎲"
  ["creative-art"]="🎨"
  ["photography"]="📷"
  ["film-cinema"]="🎬"
  ["writing"]="✍️"
  ["language-exchange"]="🗣️"
  ["hiking-outdoors"]="🥾"
  ["cycling"]="🚴"
  ["dance"]="💃"
  ["improv-comedy"]="🎭"
  ["music-open-mic"]="🎵"
  ["climbing"]="🧗"
  ["pickleball"]="🏓"
  ["pottery-ceramics"]="🏺"
  ["yoga-wellness"]="🧘"
  ["sauna-cold-plunge"]="🧊"
  ["mindfulness-meditation"]="🧘"
  ["mens-groups"]="👔"
  ["maker-spaces"]="🔧"
  ["philosophy-intellectual"]="🤔"
  ["book-clubs"]="📚"
  ["tech-startup"]="💼"
  ["coworking"]="💻"
  ["volunteer"]="🌿"
  ["vinyl-listening-bars"]="🎵"
  ["chess"]="♟️"
  ["underground-dj"]="🎧"
  ["poetry-spoken-word"]="🎤"
  ["tarot-astrology"]="🔮"
  ["pub-trivia"]="🧠"
  ["zine-risograph"]="📖"
  ["astronomy-stargazing"]="🔭"
  ["foraging-nature"]="🍄"
  ["birdwatching"]="🐦"
  ["karaoke"]="🎤"
  ["resources"]="🔗"
)

# Ordered list for sidebar
categories_ordered=(
  "dinner-supper-clubs"
  "social-friend-clubs"
  "run-clubs"
  "board-games"
  "creative-art"
  "photography"
  "film-cinema"
  "writing"
  "language-exchange"
  "hiking-outdoors"
  "cycling"
  "dance"
  "improv-comedy"
  "music-open-mic"
  "climbing"
  "pickleball"
  "pottery-ceramics"
  "yoga-wellness"
  "sauna-cold-plunge"
  "mindfulness-meditation"
  "mens-groups"
  "maker-spaces"
  "philosophy-intellectual"
  "book-clubs"
  "tech-startup"
  "coworking"
  "volunteer"
  "vinyl-listening-bars"
  "chess"
  "underground-dj"
  "poetry-spoken-word"
  "tarot-astrology"
  "pub-trivia"
  "zine-risograph"
  "astronomy-stargazing"
  "foraging-nature"
  "birdwatching"
  "karaoke"
  "resources"
)

# Convert group name to anchor slug
slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Convert markdown to HTML with anchor links on h2
md_to_html() {
  local in_list=false
  cat "$1" | \
    sed 's/^# \(.*\)//' | \
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Handle h2
      if [[ "$line" =~ ^##[[:space:]](.+)$ ]]; then
        if $in_list; then echo "</ul>"; in_list=false; fi
        h2_text="${BASH_REMATCH[1]}"
        anchor=$(slugify "$h2_text")
        echo "<h2 id=\"$anchor\">$h2_text<a href=\"#$anchor\" class=\"anchor\">#</a></h2>"
      # Handle h3
      elif [[ "$line" =~ ^###[[:space:]](.+)$ ]]; then
        if $in_list; then echo "</ul>"; in_list=false; fi
        echo "<h3>${BASH_REMATCH[1]}</h3>"
      # Handle list items
      elif [[ "$line" =~ ^-[[:space:]](.+)$ ]]; then
        if ! $in_list; then echo "<ul>"; in_list=true; fi
        item="${BASH_REMATCH[1]}"
        # Convert **bold**
        item=$(echo "$item" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g')
        # Convert [text](url)
        item=$(echo "$item" | sed 's/\[\([^]]*\)\](\([^)]*\))/<a href="\2">\1<\/a>/g')
        echo "<li>$item</li>"
      # Handle hr
      elif [[ "$line" == "---" ]]; then
        if $in_list; then echo "</ul>"; in_list=false; fi
        echo "<hr>"
      # Skip empty lines
      elif [[ -z "$line" ]]; then
        continue
      fi
    done
  if $in_list; then echo "</ul>"; fi
}

# Generate sidebar HTML
generate_sidebar() {
  local current_slug="$1"
  
  echo '<nav class="sidebar">'
  echo '  <ul>'
  
  for slug in "${categories_ordered[@]}"; do
    local title="${titles[$slug]}"
    local emoji="${emojis[$slug]}"
    local active=""
    [ "$slug" = "$current_slug" ] && active=' class="active"'
    echo "    <li><a href=\"/${slug}/\"${active}><span class=\"emoji\">${emoji}</span> ${title}</a></li>"
  done
  
  echo '  </ul>'
  echo '  <div class="sidebar-footer">'
  echo '    <a href="/submit/">+ Submit a group</a><br>'
  echo '    <a href="#" onclick="goRandom()">🎲 Random</a><br>'
  echo '    <span id="total-views"></span><br>'
  echo "    Updated ${BUILD_DATE_HUMAN}<br>"
  echo '    Created by <a href="https://bollenbach.ca" target="_blank">Patrick Bollenbach</a>'
  echo '  </div>'
  echo '</nav>'
}

# Common scripts
SCRIPTS='<script>
const categories = ['"$(printf '"%s",' "${categories_ordered[@]}" | sed 's/,$//')"'];
function goRandom() {
  const cat = categories[Math.floor(Math.random() * categories.length)];
  window.location.href = "/" + cat + "/";
}
fetch("https://vancouver-communities-stats.recipekit.workers.dev/")
  .then(r => r.json())
  .then(data => {
    const path = window.location.pathname;
    const pageViews = data.pages[path] || 0;
    const totalViews = data.total.pageviews || 0;
    const pageCounter = document.getElementById("page-views");
    if (pageCounter) pageCounter.textContent = pageViews.toLocaleString() + " views";
    const totalCounter = document.getElementById("total-views");
    if (totalCounter) totalCounter.textContent = totalViews.toLocaleString() + " total views";
    const homepageTotal = document.getElementById("homepage-total-views");
    if (homepageTotal) homepageTotal.textContent = totalViews.toLocaleString() + " views";
  })
  .catch(() => {});
</script>
<script src="/_build/main.js"></script>'

echo "Building site..."

# Build index (home page)
cat > "$SITE_DIR/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vancouver Community Directory - Local Groups, Clubs & Meetups</title>
  <meta name="description" content="A comprehensive guide to groups, clubs, meetups, and events for connection and community in Vancouver, BC.">
  <meta property="og:title" content="Vancouver Community Directory">
  <meta property="og:description" content="Find groups, clubs, meetups, and events for connection and community in Vancouver, BC.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="${SITE_URL}/">
  <meta property="og:image" content="${SITE_URL}/og-image.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Vancouver Community Directory">
  <meta name="twitter:description" content="Find groups, clubs, meetups, and events for connection and community in Vancouver, BC.">
  <meta name="twitter:image" content="${SITE_URL}/og-image.png">
  <link rel="canonical" href="${SITE_URL}/">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <link rel="alternate" type="application/rss+xml" title="Vancouver Community Directory" href="/feed.xml">
  <script defer src="https://data.kwconcerts.ca/script.js" data-website-id="ce0a9531-1032-4e43-a3a6-5c93cf9513f6"></script>
  <link rel="stylesheet" href="/_build/style.css">
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebSite",
    "name": "Vancouver Community Directory",
    "url": "${SITE_URL}",
    "description": "A comprehensive guide to groups, clubs, meetups, and events for connection and community in Vancouver, BC.",
    "areaServed": {
      "@type": "City",
      "name": "Vancouver",
      "address": {
        "@type": "PostalAddress",
        "addressRegion": "BC",
        "addressCountry": "CA"
      }
    },
    "publisher": {
      "@type": "Person",
      "name": "Patrick Bollenbach",
      "url": "https://bollenbach.ca"
    }
  }
  </script>
</head>
<body>
<header class="site-header">
  <a href="/" class="logo">Vancouver Community</a>
  <h1 class="page-title">Find your community in Vancouver</h1>
</header>
<div class="main-container">
$(generate_sidebar "")
<main class="content">
  <div class="welcome">
    <p>Vancouver can feel like a hard city to make friends. I built this directory to help.</p>
    <p>It's a collection of social groups, clubs, meetups, and events across 40+ categories — <a href="/run-clubs/">run clubs</a>, <a href="/hiking-outdoors/">hiking groups</a>, <a href="/book-clubs/">book clubs</a>, <a href="/board-games/">board game nights</a>, <a href="/creative-art/">art communities</a>, and more.</p>
    <p>This is a community project. If you know a group that should be listed, <a href="/submit/">add it</a>. If something's outdated, every page has a "suggest edit" link.</p>
    <p style="margin-top: 20px;">
      <a href="/submit/" style="margin-right: 15px;">+ Submit a group</a>
      <a href="#" onclick="goRandom(); return false;">🎲 Random category</a>
    </p>
    <hr style="margin: 25px 0;">
    <p style="font-size: 0.9em; color: #666;">Made by <a href="https://bollenbach.ca">Patrick Bollenbach</a> in Vancouver. <span id="homepage-total-views"></span></p>
  </div>
</main>
</div>
${SCRIPTS}
</body>
</html>
HTMLEOF
echo "  Built: index"

# Build submit page
mkdir -p "$SITE_DIR/submit"
cat > "$SITE_DIR/submit/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Submit a Group | Vancouver Community Directory</title>
  <meta name="description" content="Submit a community group, club, or meetup to be added to the Vancouver Community Directory.">
  <link rel="canonical" href="${SITE_URL}/submit/">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <script defer src="https://data.kwconcerts.ca/script.js" data-website-id="ce0a9531-1032-4e43-a3a6-5c93cf9513f6"></script>
  <link rel="stylesheet" href="/_build/style.css">
</head>
<body>
<header class="site-header">
  <a href="/" class="logo">Vancouver Community</a>
  <h1 class="page-title">Submit a Group</h1>
</header>
<div class="main-container">
$(generate_sidebar "submit")
<main class="content">
  <p>Know a community, club, or meetup that should be listed? Fill out the form below.</p>
  
  <form id="submit-form" style="margin-top: 20px;">
    <div style="margin-bottom: 15px;">
      <label style="display: block; margin-bottom: 5px; font-weight: 500;">Group Name *</label>
      <input type="text" name="name" required style="width: 100%; padding: 8px; border: 1px solid #ddd; font-family: inherit; font-size: inherit;">
    </div>
    
    <div style="margin-bottom: 15px;">
      <label style="display: block; margin-bottom: 5px; font-weight: 500;">Category *</label>
      <select name="category" required style="width: 100%; padding: 8px; border: 1px solid #ddd; font-family: inherit; font-size: inherit;">
        <option value="">Select a category...</option>
        <option value="Run Clubs">Run Clubs</option>
        <option value="Social/Friend Clubs">Social/Friend Clubs</option>
        <option value="Dinner/Supper Clubs">Dinner/Supper Clubs</option>
        <option value="Board Games">Board Games</option>
        <option value="Creative/Art">Creative/Art</option>
        <option value="Other">Other</option>
      </select>
    </div>
    
    <div style="margin-bottom: 15px;">
      <label style="display: block; margin-bottom: 5px; font-weight: 500;">What is it? *</label>
      <textarea name="description" required rows="3" style="width: 100%; padding: 8px; border: 1px solid #ddd; font-family: inherit; font-size: inherit;" placeholder="What does this group do?"></textarea>
    </div>
    
    <div style="margin-bottom: 15px;">
      <label style="display: block; margin-bottom: 5px; font-weight: 500;">Website or Social Link</label>
      <input type="url" name="link" style="width: 100%; padding: 8px; border: 1px solid #ddd; font-family: inherit; font-size: inherit;" placeholder="https://...">
    </div>
    
    <button type="submit" style="background: #222; color: #fff; padding: 10px 20px; border: none; cursor: pointer; font-family: inherit; font-size: inherit;">Submit</button>
    <p id="form-status" style="margin-top: 10px; color: #666;"></p>
  </form>
  
  <script>
  document.getElementById('submit-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const status = document.getElementById('form-status');
    const btn = e.target.querySelector('button');
    btn.disabled = true;
    btn.textContent = 'Submitting...';
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData);
    try {
      const res = await fetch('https://vancouver-community-submit.recipekit.workers.dev/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });
      const result = await res.json();
      if (result.success) {
        status.style.color = '#2a7d2a';
        status.textContent = '✓ ' + result.message;
        e.target.reset();
      } else {
        throw new Error(result.error || 'Submission failed');
      }
    } catch (err) {
      status.style.color = '#c00';
      status.textContent = 'Error: ' + err.message;
    }
    btn.disabled = false;
    btn.textContent = 'Submit';
  });
  </script>
</main>
</div>
${SCRIPTS}
</body>
</html>
HTMLEOF
echo "  Built: submit"

# Build each category page
for mdfile in ${SOURCE_DIR}*.md; do
  [[ "$mdfile" == *"README.md" ]] && continue
  [[ "$mdfile" == *"CONTRIBUTING.md" ]] && continue
  [ ! -f "$mdfile" ] && continue
  
  slug="$(basename "${mdfile%.md}")"
  title="${titles[$slug]:-}"
  [ -z "$title" ] && continue  # Skip if not a known category
  
  desc="${descriptions[$slug]:-}"
  emoji="${emojis[$slug]:-}"
  
  mkdir -p "$SITE_DIR/$slug"
  
  content=$(md_to_html "$mdfile")
  
  cat > "$SITE_DIR/$slug/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} in Vancouver | Vancouver Community Directory</title>
  <meta name="description" content="${desc}">
  <meta property="og:title" content="${title} in Vancouver">
  <meta property="og:description" content="${desc}">
  <meta property="og:type" content="website">
  <meta property="og:url" content="${SITE_URL}/${slug}/">
  <meta property="og:image" content="${SITE_URL}/og-image.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${title} in Vancouver">
  <meta name="twitter:description" content="${desc}">
  <meta name="twitter:image" content="${SITE_URL}/og-image.png">
  <link rel="canonical" href="${SITE_URL}/${slug}/">
  <link rel="icon" href="/favicon.svg" type="image/svg+xml">
  <link rel="alternate" type="application/rss+xml" title="Vancouver Community Directory" href="/feed.xml">
  <script defer src="https://data.kwconcerts.ca/script.js" data-website-id="ce0a9531-1032-4e43-a3a6-5c93cf9513f6"></script>
  <link rel="stylesheet" href="/_build/style.css">
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    "name": "${title} in Vancouver",
    "description": "${desc}",
    "url": "${SITE_URL}/${slug}/",
    "about": {
      "@type": "Thing",
      "name": "${title}"
    },
    "isPartOf": {
      "@type": "WebSite",
      "name": "Vancouver Community Directory",
      "url": "${SITE_URL}"
    }
  }
  </script>
</head>
<body>
<header class="site-header">
  <a href="/" class="logo">Vancouver Community</a>
  <h1 class="page-title">${emoji} ${title} in Vancouver</h1>
</header>
<div class="main-container">
$(generate_sidebar "$slug")
<main class="content">
${content}
  <hr style="margin: 25px 0;">
  <p style="color: #666; font-size: 0.9em;">
    <span id="page-views"></span>
    <span style="margin-left: 10px;">·</span>
    <a href="#" onclick="openEditModal('${slug}'); return false;" style="margin-left: 10px;">✏️ Suggest Edit</a>
  </p>
</main>
</div>

<!-- Edit Modal -->
<div id="edit-modal" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 1000; overflow: auto;">
  <div style="background: #fff; max-width: 800px; margin: 40px auto; padding: 25px; border-radius: 8px; position: relative;">
    <button onclick="closeEditModal()" style="position: absolute; top: 15px; right: 15px; background: none; border: none; font-size: 24px; cursor: pointer; color: #666;">&times;</button>
    <h2 style="margin-bottom: 15px;">Suggest Edit</h2>
    <p style="margin-bottom: 15px; color: #666;">Edit the content below. Your changes will be reviewed.</p>
    <form id="edit-form">
      <div style="margin-bottom: 15px;">
        <label style="display: block; margin-bottom: 5px; font-weight: 500;">Edit Summary *</label>
        <input type="text" name="summary" required style="width: 100%; padding: 8px; border: 1px solid #ddd; font-family: inherit;" placeholder="Brief description of your changes">
      </div>
      <div style="margin-bottom: 15px;">
        <label style="display: block; margin-bottom: 5px; font-weight: 500;">Content</label>
        <textarea id="edit-content" name="content" rows="20" style="width: 100%; padding: 8px; border: 1px solid #ddd; font-family: monospace; font-size: 13px;"></textarea>
      </div>
      <input type="hidden" name="category" id="edit-category">
      <button type="submit" style="background: #222; color: #fff; padding: 10px 20px; border: none; cursor: pointer; font-family: inherit;">Submit Edit</button>
      <span id="edit-status" style="margin-left: 15px; color: #666;"></span>
    </form>
  </div>
</div>

<script>
async function openEditModal(category) {
  document.getElementById('edit-modal').style.display = 'block';
  document.getElementById('edit-content').value = 'Loading...';
  document.getElementById('edit-category').value = category;
  try {
    const res = await fetch('https://vancouver-community-submit.recipekit.workers.dev/content/' + category);
    const data = await res.json();
    document.getElementById('edit-content').value = data.success ? data.content : 'Error loading content';
  } catch (err) {
    document.getElementById('edit-content').value = 'Error loading content';
  }
}
function closeEditModal() { document.getElementById('edit-modal').style.display = 'none'; }
document.getElementById('edit-modal').addEventListener('click', (e) => { if (e.target.id === 'edit-modal') closeEditModal(); });
document.getElementById('edit-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const btn = e.target.querySelector('button[type="submit"]');
  const status = document.getElementById('edit-status');
  btn.disabled = true;
  btn.textContent = 'Submitting...';
  const formData = new FormData(e.target);
  try {
    const res = await fetch('https://vancouver-community-submit.recipekit.workers.dev/edit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(formData))
    });
    const result = await res.json();
    if (result.success) {
      status.style.color = '#2a7d2a';
      status.textContent = '✓ ' + result.message;
      setTimeout(closeEditModal, 2000);
    } else throw new Error(result.error);
  } catch (err) {
    status.style.color = '#c00';
    status.textContent = 'Error: ' + err.message;
  }
  btn.disabled = false;
  btn.textContent = 'Submit Edit';
});
</script>

${SCRIPTS}
</body>
</html>
HTMLEOF

  echo "  Built: $slug"
done

# Generate sitemap.xml
cat > "$SITE_DIR/sitemap.xml" << XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${SITE_URL}/</loc>
    <lastmod>${BUILD_DATE}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
XMLEOF

for slug in "${categories_ordered[@]}"; do
  cat >> "$SITE_DIR/sitemap.xml" << XMLEOF
  <url>
    <loc>${SITE_URL}/${slug}/</loc>
    <lastmod>${BUILD_DATE}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
XMLEOF
done

echo "</urlset>" >> "$SITE_DIR/sitemap.xml"
echo "  Built: sitemap.xml"

# Generate robots.txt
cat > "$SITE_DIR/robots.txt" << TXTEOF
User-agent: *
Allow: /

Sitemap: ${SITE_URL}/sitemap.xml
TXTEOF
echo "  Built: robots.txt"

# Generate RSS feed
cat > "$SITE_DIR/feed.xml" << RSSEOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
  <title>Vancouver Community Directory</title>
  <description>A comprehensive guide to groups, clubs, meetups, and events in Vancouver, BC.</description>
  <link>${SITE_URL}</link>
  <atom:link href="${SITE_URL}/feed.xml" rel="self" type="application/rss+xml"/>
  <lastBuildDate>$(date -R)</lastBuildDate>
RSSEOF

for slug in "${categories_ordered[@]}"; do
  title="${titles[$slug]}"
  desc="${descriptions[$slug]}"
  cat >> "$SITE_DIR/feed.xml" << RSSEOF
  <item>
    <title>${title}</title>
    <description>${desc}</description>
    <link>${SITE_URL}/${slug}/</link>
    <guid>${SITE_URL}/${slug}/</guid>
  </item>
RSSEOF
done

cat >> "$SITE_DIR/feed.xml" << RSSEOF
</channel>
</rss>
RSSEOF
echo "  Built: feed.xml"

echo "Done! Site built in $SITE_DIR/"
