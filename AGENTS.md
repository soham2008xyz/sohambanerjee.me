# AGENTS.md

Personal blog (Jekyll) at sohambanerjee.me. GitHub Pages + Surge staging.

## Stack

- Ruby 3.2.3, Jekyll 3.10.0, Bundler
- SASS (`.scss`) with Bourbon library
- Liquid templating
- No Node.js build step

## Commands

```bash
bundle install            # install gems
bundle exec jekyll serve  # local dev server (http://localhost:4000)
bundle exec jekyll build  # build to _site/
```

No local lint, typecheck, or test suite. CI runs Lighthouse after deploy.

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

## Gotchas

- Disqus comments enabled (shortname: `sohambanerjee-me`) - present in all post layouts
- Google Analytics is commented out in `_config.yml` (no GA4 ID set)
- Old `.gitlab-ci.yml` exists in repo root - it's stale, ignore it
- `_includes/google_analytics.html` is currently empty/disabled
- Font Awesome 6.x in use (fa-solid, fa-regular prefixes)
- Permalink pattern: `/:year/:month/:day/:title/`
