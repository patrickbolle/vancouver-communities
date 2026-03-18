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
  ["mindfulness-meditation"]="🪷"
  ["mens-groups"]="👔"
  ["maker-spaces"]="🔧"
  ["philosophy-intellectual"]="🤔"
  ["book-clubs"]="📚"
  ["tech-startup"]="💼"
  ["coworking"]="💻"
  ["volunteer"]="🌿"
  ["vinyl-listening-bars"]="💿"
  ["chess"]="♟️"
  ["underground-dj"]="🎧"
  ["poetry-spoken-word"]="🎤"
  ["tarot-astrology"]="🔮"
  ["pub-trivia"]="🧠"
  ["zine-risograph"]="📖"
  ["astronomy-stargazing"]="🔭"
  ["foraging-nature"]="🍄"
  ["birdwatching"]="🐦"
  ["karaoke"]="🎙️"
  ["resources"]="🔗"
)

# Group counts per category (## headings before first ---)
declare -A counts

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

# Homepage category groups (theme → space-separated slugs)
groups_ordered=("outdoor" "social" "creative" "mind-body" "intellectual" "work-tech" "community")
declare -A group_labels=(
  ["outdoor"]="Outdoor &amp; Active"
  ["social"]="Social"
  ["creative"]="Creative"
  ["mind-body"]="Mind &amp; Body"
  ["intellectual"]="Intellectual"
  ["work-tech"]="Work &amp; Tech"
  ["community"]="Community"
)
group_outdoor="run-clubs hiking-outdoors cycling climbing pickleball sauna-cold-plunge"
group_social="dinner-supper-clubs social-friend-clubs language-exchange pub-trivia karaoke underground-dj"
group_creative="creative-art photography film-cinema writing poetry-spoken-word zine-risograph music-open-mic"
group_mind_body="yoga-wellness mindfulness-meditation dance pottery-ceramics foraging-nature birdwatching astronomy-stargazing tarot-astrology"
group_intellectual="book-clubs philosophy-intellectual chess board-games improv-comedy"
group_work_tech="tech-startup coworking maker-spaces volunteer"
group_community="mens-groups vinyl-listening-bars resources"

# Compute group counts from markdown files
for slug in "${categories_ordered[@]}"; do
  mdfile="${SOURCE_DIR}${slug}.md"
  if [ -f "$mdfile" ]; then
    counts[$slug]=$(awk '/^---$/{exit} /^## /{n++} END{print n+0}' "$mdfile")
  else
    counts[$slug]=0
  fi
done

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
        item=$(echo "$item" | sed 's/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g')
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

# Generate sidebar HTML (grouped)
generate_sidebar() {
  local current_slug="$1"

  echo '<nav class="sidebar" id="sidebar">'
  echo '  <a href="/" class="sidebar-logo">Vancouver Community</a>'
  echo '  <ul>'

  for group in "${groups_ordered[@]}"; do
    local label="${group_labels[$group]}"
    local var_name="group_${group//-/_}"
    local slugs="${!var_name}"
    echo "    <li class=\"sidebar-group-label\">${label}</li>"
    for slug in $slugs; do
      local title="${titles[$slug]}"
      local emoji="${emojis[$slug]}"
      local count="${counts[$slug]}"
      local active=""
      [ "$slug" = "$current_slug" ] && active=' class="active"'
      local count_html=""
      [ "$count" -gt 0 ] 2>/dev/null && count_html="<span class=\"count\">${count}</span>"
      echo "    <li><a href=\"/${slug}/\"${active}><span class=\"emoji\">${emoji}</span> ${title}${count_html}</a></li>"
    done
  done
  
  echo '  </ul>'
  echo '  <div class="sidebar-footer">'
  echo '    <a href="/submit/">+ Submit a group</a><br>'
  echo '    <a href="#" onclick="goRandom()">🎲 Random</a><br>'
  echo '    <span id="total-views"></span><br>'
  echo "    Updated ${BUILD_DATE_HUMAN}<br>"
  echo '    Created by <a href="https://bollenbach.ca" target="_blank" rel="noopener noreferrer">Patrick Bollenbach</a>'
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

# Compute total groups across all categories
total_groups=0
for slug in "${categories_ordered[@]}"; do
  total_groups=$((total_groups + counts[$slug]))
done

# Build index (home page) — three-part: head, card loop, footer
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
  <link rel="stylesheet" href="/_build/style.css?v=1773792475">
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
<body class="homepage">
<header class="site-header">
  <a href="/" class="logo">Vancouver Community</a>
  <button class="sidebar-toggle" aria-expanded="false" aria-controls="sidebar">Browse</button>
</header>
<div class="main-container">
$(generate_sidebar "")
<main class="content content-wide">
  <div class="homepage-header">
    <div class="homepage-header-left">
      <h1 class="homepage-lede">Vancouver can feel like a hard city to make friends in.</h1>
      <p class="homepage-meta">${total_groups}+ groups, clubs &amp; meetups across ${#categories_ordered[@]} categories.
        <a href="/submit/" class="homepage-action">+ Add a group</a>
        <a href="#" onclick="goRandom(); return false;" class="homepage-action">Random</a>
      </p>
      <input type="search" class="search-input search-input--homepage" placeholder="Search categories..." aria-label="Search categories" id="homepage-search">
    </div>
    <aside class="homepage-about">
      <p class="about-text">A community project by <a href="https://bollenbach.ca">Patrick Bollenbach</a>. Built because this city has way more going on than people realize.</p>
      <div class="about-links">
        <a href="https://cuento.app">cuento.app</a>
        <a href="https://runclubs.ca/vancouver">runclubs.ca</a>
        <a href="https://bollenbach.ca">bollenbach.ca</a>
      </div>
      <p class="about-stats"><span id="homepage-total-views"></span></p>
    </aside>
  </div>
  <div class="homepage-groups" id="homepage-groups">
HTMLEOF

# Append grouped category lists
for group in "${groups_ordered[@]}"; do
  label="${group_labels[$group]}"
  var_name="group_${group//-/_}"
  slugs="${!var_name}"
  cat >> "$SITE_DIR/index.html" << GROUPEOF
    <div class="cat-group">
      <p class="cat-group-heading">${label}</p>
      <ul class="cat-group-list">
GROUPEOF
  for slug in $slugs; do
    title="${titles[$slug]}"
    emoji="${emojis[$slug]}"
    count="${counts[$slug]}"
    count_html=""
    if [ "$count" -eq 1 ] 2>/dev/null; then
      count_html="<span class=\"cat-count\">1</span>"
    elif [ "$count" -gt 1 ] 2>/dev/null; then
      count_html="<span class=\"cat-count\">${count}</span>"
    fi
    echo "      <li><a href=\"/${slug}/\"><span class=\"cat-emoji\">${emoji}</span><span class=\"cat-name\">${title}</span>${count_html}</a></li>" >> "$SITE_DIR/index.html"
  done
  cat >> "$SITE_DIR/index.html" << GROUPEOF
      </ul>
    </div>
GROUPEOF
done

# Close groups + footer
cat >> "$SITE_DIR/index.html" << HTMLEOF
  </div>
</main>
</div>
${SCRIPTS}
</body>
</html>
HTMLEOF
echo "  Built: index"

# Generate category <option> list for submit form
category_options=""
for slug in "${categories_ordered[@]}"; do
  t="${titles[$slug]}"
  category_options="${category_options}        <option value=\"${t}\">${t}</option>"$'\n'
done

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
  <link rel="stylesheet" href="/_build/style.css?v=1773792475">
</head>
<body>
<header class="site-header">
  <a href="/" class="logo">Vancouver Community</a>
  <h1 class="page-title">Submit a Group</h1>
  <button class="sidebar-toggle" aria-expanded="false" aria-controls="sidebar">Browse</button>
</header>
<div class="main-container">
$(generate_sidebar "submit")
<main class="content">
  <p>Know a community, club, or meetup that should be listed? Fill out the form below.</p>

  <form id="submit-form" class="form">
    <div class="form-field">
      <label class="form-label" for="submit-name">Group Name *</label>
      <input class="form-input" type="text" id="submit-name" name="name" required>
    </div>
    <div class="form-field">
      <label class="form-label" for="submit-category">Category *</label>
      <select class="form-input" id="submit-category" name="category" required>
        <option value="">Select a category...</option>
${category_options}        <option value="Other">Other</option>
      </select>
    </div>
    <div class="form-field">
      <label class="form-label" for="submit-description">What is it? *</label>
      <textarea class="form-input" id="submit-description" name="description" required rows="3" placeholder="What does this group do?"></textarea>
    </div>
    <div class="form-field">
      <label class="form-label" for="submit-link">Website or Social Link</label>
      <input class="form-input" type="url" id="submit-link" name="link" placeholder="https://...">
    </div>
    <button class="form-submit" type="submit">Submit</button>
    <p class="form-status" id="form-status"></p>
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
        status.className = 'form-status success';
        status.textContent = '✓ ' + result.message;
        e.target.reset();
      } else {
        throw new Error(result.error || 'Submission failed');
      }
    } catch (err) {
      status.className = 'form-status error';
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

  # Count label for page title
  count_val="${counts[$slug]:-0}"
  count_label=""
  if [ "$count_val" -eq 1 ] 2>/dev/null; then
    count_label="<span class=\"header-count\">1 group</span>"
  elif [ "$count_val" -gt 1 ] 2>/dev/null; then
    count_label="<span class=\"header-count\">${count_val} groups</span>"
  fi

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
  <link rel="stylesheet" href="/_build/style.css?v=1773792475">
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
<body class="category-page">
<header class="site-header">
  <a href="/" class="logo">Vancouver Community</a>
  <button class="sidebar-toggle" aria-expanded="false" aria-controls="sidebar">Browse</button>
</header>
<div class="main-container">
$(generate_sidebar "$slug")
<main class="content">
  <div class="category-hero">
    <h1 class="category-title">${title} in Vancouver</h1>
    <p class="category-desc">${desc}</p>
    <div class="category-actions">
      <a href="/submit/" class="cat-action">+ Submit a group</a>
      <a href="#" onclick="openEditModal('${slug}'); return false;" class="cat-action">✏️ Suggest an edit</a>
      <span id="page-views" class="cat-views"></span>
    </div>
  </div>
${content}
</main>
</div>

<!-- Suggest Edit Modal -->
<div id="edit-modal" class="edit-modal" role="dialog" aria-modal="true" aria-labelledby="edit-modal-title">
  <div class="edit-modal-inner">
    <button class="edit-modal-close" onclick="closeEditModal()" aria-label="Close">&times;</button>
    <h2 id="edit-modal-title" class="edit-modal-title">Suggest an edit</h2>
    <p class="edit-modal-desc">What needs to change? A closed group, wrong link, new info — anything helps.</p>
    <form id="edit-form" class="form">
      <div class="form-field">
        <label class="form-label" for="edit-summary">What should change? *</label>
        <textarea class="form-input" id="edit-summary" name="summary" required rows="4" placeholder="e.g. Social Run Club meets on Tuesdays now, not Wednesdays. New website: ..."></textarea>
      </div>
      <div class="form-field">
        <label class="form-label" for="edit-name">Your name (optional)</label>
        <input class="form-input" type="text" id="edit-name" name="name" placeholder="Patrick">
      </div>
      <input type="hidden" name="category" id="edit-category">
      <button class="form-submit" type="submit">Send suggestion</button>
      <span class="form-status" id="edit-status"></span>
    </form>
  </div>
</div>

<script>
var _editOpener = null;
function openEditModal(category) {
  var modal = document.getElementById('edit-modal');
  _editOpener = document.activeElement;
  document.getElementById('edit-category').value = category;
  modal.style.display = 'block';
  var closeBtn = modal.querySelector('.edit-modal-close');
  if (closeBtn) closeBtn.focus();
}
function closeEditModal() {
  document.getElementById('edit-modal').style.display = 'none';
  if (_editOpener) { _editOpener.focus(); _editOpener = null; }
}
document.getElementById('edit-modal').addEventListener('click', (e) => { if (e.target.id === 'edit-modal') closeEditModal(); });
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && document.getElementById('edit-modal').style.display === 'block') closeEditModal();
});
document.getElementById('edit-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const btn = e.target.querySelector('button[type="submit"]');
  const status = document.getElementById('edit-status');
  btn.disabled = true;
  btn.textContent = 'Sending...';
  const formData = new FormData(e.target);
  try {
    const res = await fetch('https://vancouver-community-submit.recipekit.workers.dev/edit', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(Object.fromEntries(formData))
    });
    const result = await res.json();
    if (result.success) {
      status.className = 'form-status success';
      status.textContent = '✓ Got it, thanks!';
      e.target.reset();
      setTimeout(closeEditModal, 2000);
    } else throw new Error(result.error || 'Something went wrong');
  } catch (err) {
    status.className = 'form-status error';
    status.textContent = 'Could not send — try emailing directly.';
  }
  btn.disabled = false;
  btn.textContent = 'Send suggestion';
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
