# Copilot instructions for sohambanerjee.me

## Build and validation commands

- Install gems: `bundle install`
- Install lint tooling: `npm install`
- Run the site locally: `bundle exec jekyll serve`
- Build the production output into `_site/`: `bundle exec jekyll build`
- Run the full local check suite: `bundle exec rake test`
- Run a single front-matter check: `bundle exec rake test:frontmatter`
- Run html-proofer against a built site: `bundle exec rake test:html`
- Run CSS lint: `npm run lint:css`
- Run JS lint: `npm run lint:js`
- Node is dev-only here; the site still builds with Jekyll/Ruby, and `css/main.sass` is validated by Jekyll rather than stylelint.
- `HTMLPROOFER_EXTERNAL=1 bundle exec rake test:html` includes external links; by default html-proofer skips them.
- Bundler is configured to install gems into `vendor/bundle` via `.bundle/config`. If a local build starts reading `vendor/bundle/.../site_template/_posts`, treat that as an environment issue with the vendored gems path inside the repo rather than a content error in the site itself.
- CI runs on `master`: `lint` (front matter, Sass, JS) and `build` (Jekyll build + html-proofer) gate `deploy` and `surge`, then `test` runs Lighthouse against the deployed Surge URL.

## High-level architecture

- This is a static Jekyll blog. `_config.yml` is the site-wide source of truth for metadata such as the title, author, social links, permalink pattern, Disqus shortname, and build exclusions.
- Layouts are layered:
  - `_layouts/default.html` is the outer shell and pulls in `_includes/head.html`, `_includes/header.html`, `_includes/footer.html`, and `_includes/javascripts.html`.
  - `_layouts/page.html` wraps standalone pages such as `about.md` and `contact.md`.
  - `_layouts/post.html` handles article pages, including hero images, post metadata, share links, author/footer chrome, and Disqus.
- `index.html` is its own homepage template. It renders a featured-post section from `site.tags.featured` and a separate paginated list for all posts.
- Styling compiles from the indented-syntax entrypoint `css/main.sass`, which imports partials from `_sass/` and uses Bourbon mixins.
- Client-side behavior is light and mostly wired through `_includes/javascripts.html`: it loads the site JS, reveals Disqus comment counts, and computes reading-time UI from Liquid-rendered `data-word-count` attributes.
- `assets/js/index.js` is vanilla JavaScript and handles image wrappers, responsive embeds, parallax on hero images, and same-page smooth scrolling.

## Key repository conventions

- The repo has no Node build step for the site itself. Use the Ruby/Jekyll commands above for local work.
- The default branch is `master`, not `main`. Deployment and CI are tied to pushes on `master`.
- Posts live in `_posts/` and must use the `YYYY-MM-DD-slug.md` filename format.
- Post front matter is not optional here. New posts should include `layout: post`, `title`, `date`, `categories`, `tags`, `image`, and `image2`.
- The `featured` tag is functional, not cosmetic: it drives the homepage featured-post section.
- Post images belong under `assets/article_images/YYYY-MM-DD-slug/`.
- Drafts belong in `_drafts/` and do not use the date prefix.
- Top-level content pages such as `about.md` and `contact.md` use `layout: page` plus an explicit `permalink`.
- Keep styles in the existing Sass style: edit `css/main.sass` or `_sass/` partials using indented Sass syntax, not SCSS braces.
- `npm run lint:css` only checks `_sass/*.scss`; `css/main.sass` stays unlinted because the indented-Sass parser used by stylelint does not handle its nested rules well.
- Google Analytics is gated by `_config.yml`. `_includes/google_analytics.html` exists, but nothing is rendered unless `site.google_analytics` is set.
- Disqus is enabled site-wide through the configured shortname and is referenced in both the post layout and shared JS.
- Font Awesome 6 naming is already in use (`fa-solid`, `fa-regular`, `fa-brands`).
- The image compression workflow only triggers on pushed `.jpg`, `.jpeg`, `.png`, and `.webp` files.
- CodeQL currently analyzes `javascript` and `ruby` on pushes and pull requests to `master`.
- `.gitlab-ci.yml` is stale and should be ignored.
