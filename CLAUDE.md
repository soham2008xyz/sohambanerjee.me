# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This repo also has an `AGENTS.md` with agent-oriented context (stack, commands, post front matter, gotchas). Read both — `AGENTS.md` is excluded from the Jekyll build itself (see `_config.yml`'s `exclude` list) but not from Claude Code's context.

## Commands

```bash
bundle install            # install gems
bundle exec jekyll serve  # local dev server (http://localhost:4000)
bundle exec jekyll build  # build to _site/
```

No lint, typecheck, or test suite exists locally. CI runs Lighthouse against the deployed site, not the build output.

## Architecture

Static Jekyll blog (Ruby 3.2.3, Jekyll via the `github-pages` gem, no Node build step). Three layouts chain together in `_layouts/`:

- `default.html` — base HTML shell, pulls in `_includes/head.html`, `_includes/header.html`, `_includes/footer.html`
- `page.html` — extends default, used for static pages (`about.md`, `contact.md`)
- `post.html` — extends default, used for `_posts/` entries; this is the largest layout (~10K) and handles the post-specific chrome (hero image, Disqus, share icons, related posts)

Styling is SCSS (`_sass/`) compiled from a single Sass-syntax (indented, not SCSS-brace) entry point at `css/main.sass`, built on the Bourbon mixin/grid library (vendored under `_sass/bourbon/`).

### Deploy pipeline (`.github/workflows/jekyll-build-deploy-test.yml`)

On push to `master`: `build` → fans out to `deploy` (GitHub Pages) and `surge` (Surge.sh staging) → `test` (Lighthouse CI via PSI, desktop + mobile, run against the Surge URL). Site is dual-hosted: production on GitHub Pages (custom domain via `CNAME`), staging mirror on Surge.

Separate workflows: `codeql.yml` (security scanning) and `compress-images.yml` (auto-opens a PR when images are pushed).

### Site config (`_config.yml`)

Drives site-wide metadata (title, author, social links, Disqus shortname, permalink pattern `/:year/:month/:day/:title/`). Google Analytics is present in `_includes/google_analytics.html` but disabled — no `google_analytics` key is set in `_config.yml`.

For post front matter requirements, image conventions, and other content-authoring details, see `AGENTS.md`.
