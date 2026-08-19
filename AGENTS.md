# AGENTS.md

Personal blog (Jekyll) at sohambanerjee.me. GitHub Pages + Surge staging.

## Stack

- Ruby 3.2.6, Jekyll 3.10.0, Bundler
- SASS (`.scss`) with Bourbon library
- Liquid templating
- No Node.js build step

## Commands

```bash
bundle install            # install gems
npm install                # install lint tooling (Node, dev-only - no build step)
bundle exec jekyll serve  # local dev server (http://localhost:4000)
bundle exec jekyll build  # build to _site/
bundle exec rake test     # front matter validation + html-proofer (builds first)
npm run lint:css          # stylelint on _sass/*.scss
npm run lint:js           # eslint on assets/js/index.js
```

Local checks: `rake test:frontmatter` validates required post front matter (see below) and that `image`/`image2` files exist; `rake test:html` builds the site and runs html-proofer against `_site/` for broken links, missing images, and missing alt text (external links are skipped by default - set `HTMLPROOFER_EXTERNAL=1` to include them). `npm run lint:css` covers the one live Sass partial, `_sass/_syntax-highlighting.scss`; `css/main.sass` (indented syntax) isn't linted - stylelint's only indented-Sass parser (`postcss-sass`) is unmaintained and crashes on this file's nested rules, so Jekyll's own Sass compiler (which fails the build on invalid Sass) is the correctness check for it instead. CI runs all of these in a `lint` job plus html-proofer in `build`, gating `deploy`/`surge`; Lighthouse still runs after deploy.

## Branch

Default branch is `master` (not `main`). All deploys and CI trigger on `master`.

## Posts

- Location: `_posts/`
- Filename: `YYYY-MM-DD-slug.md`
- Required front matter:

```yaml
---
layout: post
title: "Title"
date: YYYY-MM-DD HH:MM:SS
categories:
tags: featured topic1 topic2
image: /assets/article_images/YYYY-MM-DD-slug/hero.jpg
image2: /assets/article_images/YYYY-MM-DD-slug/hero.jpg
---
```

- Add `featured` tag to show in the featured section on the homepage
- Article images go in `assets/article_images/YYYY-MM-DD-slug/`
- Drafts go in `_drafts/` (no date prefix in filename)

## Styles

- SCSS files in `_sass/` (base, layout, syntax-highlighting)
- Entry point: `css/main.sass` (indent syntax, not curly braces)
- Bourbon grid/mixin library

## CI/CD

- Push to `master` triggers: Jekyll build, deploy to GitHub Pages + Surge, Lighthouse test (desktop + mobile)
- Image compression PR opens automatically when images are pushed
- Dependabot: weekly bundler + github-actions updates

## Cloud Agent environment

- Cursor: `.cursor/environment.json` (Ruby 3.2.6 + Node 24 via Dockerfile)
  - Bootstrap: `bash .cursor/install.sh` (runs `bundle install` and `npm ci`)
  - Dev server starts automatically in the `jekyll` terminal on port 4000
  - Source `source .cursor/env.sh` before interactive npm/Ruby commands if tool versions look wrong
- GitHub Copilot cloud agent: `.github/workflows/copilot-setup-steps.yml`
  - Checks out the repo, sets `LANG=C.UTF-8`, installs Ruby from `.ruby-version` with bundler cache, and installs Node from `.nvmrc` with npm cache
  - Runs `npm ci`; `ruby/setup-ruby` handles `bundle install` via `bundler-cache: true`
- Claude Code on the web: `.claude/hooks/session-start.sh`, registered as a `SessionStart` hook in `.claude/settings.json`
  - Puts rbenv's shims (respecting `.ruby-version`) on `PATH` and sets `LANG=C.UTF-8` (the base image has no locale generated, which otherwise breaks reading UTF-8 post content) via `$CLAUDE_ENV_FILE`
  - Runs `bundle install` (gems vendored to `vendor/bundle`) and `npm install`
  - Only runs remotely (`$CLAUDE_CODE_REMOTE`), does nothing locally
- Ruby version is pinned in `.ruby-version` (3.2.6); Node version in `.nvmrc` (24, Cursor only - Claude Code's web environment uses whatever Node is preinstalled)

## Gotchas

- Disqus comments enabled (shortname: `sohambanerjee-me`) - present in all post layouts
- Google Analytics is commented out in `_config.yml` (no GA4 ID set)
- Old `.gitlab-ci.yml` exists in repo root - it's stale, ignore it
- `_includes/google_analytics.html` is currently empty/disabled
- Font Awesome 6.x in use (fa-solid, fa-regular prefixes)
- Permalink pattern: `/:year/:month/:day/:title/`
