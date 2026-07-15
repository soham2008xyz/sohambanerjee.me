# Plan: Modernize Dated Dependencies in sohambanerjee.me

## Problem
The Jekyll blog (The Nonconformist) loads several third-party assets from CDNs that are
now shut down or deprecated. These are silently broken and should be modernized or
removed. No framework rewrite — this is a surgical dependency modernization scoped to
the existing Jekyll + GitHub Pages setup.

### Dead / broken dependencies (verified from code)
1. **`cdn.rawgit.com/HubSpot/pace/v1.0.0/pace.min.js`** (in `head.html`) — rawgit.com was
   shut down in 2018. The page-load progress bar does nothing.
2. **`cdn.rawgit.com/michael-lynch/reading-time/.../readingtime.min.js`** (in
   `javascripts.html`) — same dead CDN. Reading-time estimates on homepage and posts
   silently fail (the JS catches the error and removes the `.reading-time` node).
3. **`brick.a.ssl.fastly.net/...`** (in `head.html`) — the Brick font CDN was sunset.
   Body/heading webfonts fall back to system fonts (likely already happening).
4. **Universal Analytics** (`google_analytics.html`, `analytics.js`, `ga()`) — Google
   stopped processing UA data on 2023-07-01. Currently collects nothing.
5. **Dated but still-working deps**: jQuery 1.11.1, Font Awesome 4.7, animate.css 3.5.2.
   FA4 is EOL (FA5+ is current) but functional; jQuery 1.11 is very old (security
   advisories) and only used for fitvids + scroll effects.

## Approach
Replace dead CDN assets with self-hosted or maintained equivalents, and upgrade the
still-working-but-dated ones. Keep the visual design intact.

### A. Reimplement dead CDN assets (keep functionality, drop the dead CDN)
- **Pace.js** (`head.html`): The rawgit CDN is dead, but the top progress bar is a nice
  touch — reimplement it in **vanilla JS + CSS** instead of removing it:
  - Keep the existing `.pace` / `.pace-progress` CSS block in `head.html` (or move it to
    sass), but change its fill logic: a scroll-driven progress bar.
  - Add a tiny inline/external vanilla script: on `scroll`, compute
    `scrollTop / (scrollHeight - innerHeight)` and set `.pace-progress` width (and
    `right: 100% → transform: scaleX`) — no external library, no jQuery.
  - Remove the dead `cdn.rawgit.com/.../pace.min.js` `<script>`.
- **Reading-time** (`javascripts.html` + `head.html` links): Replace the dead rawgit lib
  with a self-contained, dependency-free snippet (compute words/180 wpm in plain JS,
  no jQuery/Cdn). Wire it to the existing `.words` / `.eta` / `.post-word-count` /
  `.post-reading-time` targets. This restores a feature that's currently broken.

### B. Fonts (`head.html`)
- Replace Brick CDN with a maintained source: Google Fonts
  (`fonts.googleapis.com`) serving the same families (Linux Libertine → use
  `Libertine`/serif fallback; Open Sans is on Google Fonts). Add `preconnect` hints.
- Keep the existing CSS font stack so non-webfont fallback still works.

### C. Analytics (`google_analytics.html`, `_config.yml`) — DECISION: GA4
- Replace Universal Analytics with **GA4** via `gtag.js`:
    - New `google_analytics.html` loads
    `https://www.googletagmanager.com/gtag/js?id=<MEASUREMENT_ID>` and the standard
    `gtag('config', '<MEASUREMENT_ID>')` snippet.
    - `_config.yml`: rename/repurpose `google_analytics` to hold the \*\*GA4 measurement
    ID\*\* (format `G-XXXXXXX`). Keep the same `{% if site.google_analytics %}` gate.
    - No cookie-consent banner added (out of scope); note for user that GA4 may need one
    under some jurisdictions.
- The onNewComment → analytics event hook in `post.html` stays but is re-pointed from
  `ga('send'...)` to `gtag('event', 'comment', ...)`.

### D. Dated-but-working deps — DECISION: remove jQuery
- **Font Awesome 4.7 → 6.x** via `cdnjs` (FA6 free). Map icon classes used:
  `fa-calendar-o`→`fa-regular fa-calendar`, `fa-comments-o`→`fa-regular fa-comment`,
  `fa-file-text-o`→`fa-regular fa-file-lines`, `fa-clock-o`→`fa-regular fa-clock`,
  `fa-heart`→`fa-solid fa-heart`, `fa-angle-down`→`fa-solid fa-angle-down`,
  `fa-rss`→`fa-solid fa-rss`. Use `fa-solid`/`fa-regular` prefixes (FA6 syntax).
- **jQuery removed entirely.** `javascripts.html` drops the jQuery `<script>`. Rewrite
  `assets/js/index.js` in vanilla JS:
    - Scroll parallax on `.post-image-image, .teaserimage-image` (no jQuery)
    - Smooth-scroll anchor handler (no jQuery)
    - Reading-time + disqus-count wiring: replace the dead rawgit `readingTime` plugin with
    a self-contained vanilla snippet that computes words/180 wpm from `.post-content`
    and fills `.words`/`.eta` (homepage) and `.post-word-count`/`.post-reading-time`
    (single post). No jQuery, no external lib.
- **animate.css dropped** — replace the single `animated pulse infinite` down-arrow bounce
  with a custom CSS `@keyframes` (e.g. `@keyframes pulse-bounce`) in `_sass/_base.scss` /
  `css/main.sass`, applied via a `.pulse` class. Removes another CDN dependency.

## Files to change
- `_includes/head.html` — reimplement Pace as vanilla scroll-progress bar (keep `.pace` CSS,
  drop rawgit script); replace Brick fonts with Google Fonts + `preconnect`; bump Font Awesome
  to 6.x (cdnjs); drop animate.css `<link>`
- `_includes/javascripts.html` — remove jQuery `<script>`; inline vanilla reading-time +
  disqus-count + scroll-progress logic (no rawgit, no jQuery)
- `assets/js/index.js` — rewrite scroll parallax + smooth-scroll anchors in vanilla JS
- `_includes/google_analytics.html` — replace UA (`analytics.js`/`ga`) with GA4 `gtag.js`
- `_includes/post.html` — re-point comment analytics event `ga('send')` → `gtag('event')`;
  swap `animated pulse infinite` for the custom `pulse` class
- `_config.yml` — `google_analytics` now holds the GA4 measurement ID; add font note
- `_sass/_base.scss` / `css/main.sass` — add custom `@keyframes pulse-bounce` (replaces
  animate.css)

## Out of scope
- Jekyll version upgrade, Ruby/toolchain changes
- Visual redesign, layout changes
- Migrating posts or content
- Build pipeline changes (CI stays as-is)

## Verification
- `bundle exec jekyll build` succeeds locally with no asset 404s in output
- `grep -R "rawgit|brick.a.ssl|analytics.js|jquery" _site/` → 0 matches
- Homepage: reading-time + fonts render; post page: reading-time + GA4 snippet present
- `index.js` parallax + smooth-scroll still work (manual check or Lighthouse)
- CI deploy + Lighthouse run still green
