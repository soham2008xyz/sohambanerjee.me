# Fix review gaps in PR #90 (refactor/modernize-deps)

## Context

PR #90 modernizes dead/dated third-party dependencies in this Jekyll blog (drops jQuery,
rawgit CDN scripts, Universal Analytics, Font Awesome 4, animate.css; adds vanilla JS,
GA4, Font Awesome 6, Google Fonts, a custom CSS pulse animation). A two-axis review
(Standards + Spec, against the PR's own plan doc
`.github/plans/01-modernize-dated-dependencies.md`) found concrete, verified gaps —
most importantly a live runtime bug (`ReferenceError` on every new Disqus comment) and
an incomplete icon migration that leaves some icons broken. This plan fixes all
confirmed issues before the PR merges.

**Note on repo state:** the local checkout is currently on branch `refactor/modernize-deps`
(same commit as PR #90's head, `99068e3`) — this happened during the investigation for
this plan (a `git checkout` to the existing tracking branch, no data was at risk, tree
was clean beforehand). This is the right branch to commit the fixes onto, per your
answer to work directly on the PR branch.

Also confirmed during investigation: `site.social` in `_config.yml` has exactly four
entries — `twitter`, `facebook`, `github`, `whatsapp` — all Font Awesome **brand**
icons, which resolves how the dynamic icon fix (#2 below) should be written.

## Approach

Five commits, ordered by severity (runtime bug → visually-broken-now → lower-severity
correctness → style nit → dead-code cleanup), each mapping to one confirmed issue so the
history stays bisectable.

### 1. Fix the `ga()` → `gtag()` runtime bug — `fix(analytics): repoint disqus comment event from ga() to gtag()`

`_layouts/post.html` lines 172–181: the Disqus `onNewComment` callback still calls
legacy UA `ga('send', {...})`, but `google_analytics.html` no longer defines `ga`
anywhere on the page (rewritten to GA4 `gtag.js`) — this throws `ReferenceError` every
time a comment is posted. `gtag` is defined by `_includes/javascripts.html`'s
`{% include google_analytics.html %}`, which runs earlier in page load than any user
comment, so it's safe to call from this async callback.

Replace:
```js
ga('send', {
  'hitType': 'event',
  'eventCategory': 'Comments',
  'eventAction': 'New Comment',
  'eventLabel': 'New Comment'
});
```
with:
```js
gtag('event', 'comment', {
  'event_category': 'Comments',
  'event_label': 'New Comment'
});
```
GA4's event model is `gtag('event', <name>, {params})` — there's no
hitType/eventAction in GA4. `event_category`/`event_label` aren't GA4-reserved but
preserve the original intent as free-form params. **Judgement call — flag this shape
for your review in the diff before merging**, since the PR's plan doc didn't specify
exact parameters.

### 2. Finish the Font Awesome 6 migration — `fix(icons): migrate remaining fa4 classes to font awesome 6`

These were missed when the PR migrated `_includes/footer.html` (already using
`fa-solid fa-rss` / `fa-solid fa-heart` as the reference pattern) — they still use FA4
syntax, which renders broken now that only FA6's `all.min.css` loads (no v4 shim):

- [_layouts/post.html:103](_layouts/post.html:103) — `<i class="fa fa-{{ social.icon }}"></i>` (share-icon loop)
- [_layouts/post.html:121](_layouts/post.html:121) — `<i class="fa fa-{{ social.icon }}"></i>` (author bio loop)
- [_layouts/post.html:152](_layouts/post.html:152) — `<i class="fa fa-heart" style="color: red;"></i>`
- [_layouts/post.html:153](_layouts/post.html:153) — `<i class="fa fa-rss"></i>`
- [index.html:20](index.html:20) — `<i class="fa fa-{{ social.icon }}"></i>` (header social loop)

Fix:
- The two static icons → mirror `footer.html` exactly: `fa-solid fa-heart`, `fa-solid fa-rss`.
- The three dynamic `{{ social.icon }}` occurrences → `fa-brands fa-{{ social.icon }}`
  (correct today since all four `site.social` icons are brand icons; **known
  limitation** — a future non-brand icon like `envelope` added to `_config.yml` would
  render wrong under this flat mapping. Not building speculative per-icon Liquid logic
  for a case that doesn't exist yet — just flagging it).

### 3. Restore italic font weights — `fix(fonts): request italic open sans weights from google fonts`

[_includes/head.html:79](_includes/head.html:79) only requests
`family=Open+Sans:wght@400;700` (regular/bold). The original Brick CDN link requested
`Open+Sans:400,400i,700,700i` — italic text currently falls back to synthetic/faux
italics instead of the true italic face. Fix with Google Fonts v2 combined-axis syntax:
```
family=Open+Sans:ital,wght@0,400;0,700;1,400;1,700&display=swap
```

### 4. Style consistency nit — `style(head): add "use strict" to pace progress-bar iife`

[_includes/head.html:55-73](_includes/head.html:55) — the new inline pace-bar IIFE
lacks `"use strict";`, unlike `assets/js/index.js` and `_includes/javascripts.html`
which both open with it. Add it as the first line of the IIFE body, followed by a blank
line, matching the existing pattern.

### 5. Dead code cleanup — `chore: remove orphaned pre-refactor js assets and unused variable`

- Delete orphaned, unreferenced files (confirmed via repo-wide grep — nothing includes
  them anymore after the PR's own jQuery/reading-time rewrite):
  `assets/js/jquery.fitvids.js`, `assets/js/readingTime.min.js`, and the whole
  `assets/js/min/` directory (`highlight.pack-ck.js`, `index-ck.js`,
  `jquery.fitvids-ck.js`, `jquery.ghostHunter.min-ck.js`, `readingTime.min-ck.js` — the
  directory contains only these 5 orphaned files).
- [_includes/javascripts.html:12](_includes/javascripts.html:12) — remove
  `var counts = widgets.getCount ? widgets.getCount() : [];` inside
  `disqusCountsLoaded()`; it's computed but never used — the function's actual logic
  reads `document.querySelectorAll('.disqus-comment-count')` directly.

## Critical files

- `_layouts/post.html` — commits 1 and 2
- `index.html` — commit 2
- `_includes/head.html` — commits 3 and 4
- `_includes/javascripts.html` — commit 5
- `assets/js/jquery.fitvids.js`, `assets/js/readingTime.min.js`, `assets/js/min/*` — deleted in commit 5

Reference pattern to match: `_includes/footer.html` (already-correct FA6 syntax) and
`assets/js/index.js` / `_includes/javascripts.html` (existing `"use strict"` IIFE style).

## Verification

**Environment blocker found during investigation:** the system Ruby (2.6.10) doesn't
match `.ruby-version` (3.2.3), and the installed bundler (1.17.2) doesn't match
`Gemfile.lock`'s required 2.5.10 — `bundle exec jekyll build` fails immediately as-is.
This needs to be resolved for real (e.g. `asdf install ruby 3.2.3` +
`gem install bundler -v 2.5.10`) before the build/grep checks below can run — this is a
genuine blocker, not a formality, and should not be silently skipped. (Separately:
`.gitlab-ci.yml` builds with `ruby:2.7` in CI, which itself doesn't match
`.ruby-version` — pre-existing, out of scope here, worth a follow-up.)

Once Ruby/bundler is sorted:

1. `bundle exec jekyll build` — must succeed with no errors.
2. Grep the built output:
   - `grep -RIl -E "rawgit|brick\.a\.ssl|analytics\.js|jquery" _site/` → 0 matches (the PR's own plan-doc verification step, run for real).
   - `grep -RIn 'class="fa fa-' _site/` → 0 matches (confirms the icon migration is complete in rendered output).
   - `grep -RIn "ga('send'" _site/` → 0 matches (confirms the `gtag` fix rendered correctly).
3. Serve `_site/` (`bundle exec jekyll serve` or a static server) and check via the Browser tool:
   - Homepage: reading-time shows non-empty values; header social icons render as glyphs (not tofu boxes); an `<em>` element renders true italic Open Sans; pace bar responds to scroll; no console errors.
   - Post page: same checks, plus confirm `typeof gtag === 'function'` in devtools console, and confirm no `ReferenceError` when the `onNewComment` callback logic is exercised.
   - Network tab shows a `gtag/js?id=...` request firing.
   - Parallax and smooth-scroll anchors still work.
4. `git diff` review before pushing — confirm the GA4 event shape (commit 1) and the flat `fa-brands` mapping (commit 2) read as intended; both are judgement calls flagged above for your review.
5. Push to `origin refactor/modernize-deps` only after you've reviewed the diff (explicit confirmation needed at that point — pushing updates the live PR).
