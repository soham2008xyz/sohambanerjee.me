# Add local lint/typecheck/test tooling

## Context

The repo currently has no local lint, typecheck, or test suite (documented explicitly in [AGENTS.md](AGENTS.md:20)). The only automated check is Lighthouse CI, which runs *after* deploy against the live Surge URL — it can't catch broken links, missing alt text, malformed post front matter, or style/JS mistakes before they ship. There's no build-typecheck concept for a Jekyll/Liquid/Markdown site, so "typecheck" here means the closest practical equivalents: HTML/link validation and front-matter schema validation.

The codebase surface is small and well-scoped: 1 Sass entry point (`css/main.sass`, indented syntax) + 1 live Sass partial (`_sass/_syntax-highlighting.scss`; two other `_sass/*.scss__` files are dead/unimported), 1 hand-written JS file (`assets/js/index.js`), 3 layouts, 5 includes, and 14 posts under `_posts/` with a documented required front-matter schema. No custom Ruby plugins exist, so Rubocop isn't warranted yet.

Per the user's decisions: bring in Node/npm (currently absent) for Sass/JS linting, and wire everything into CI now, gating deploy.

## Plan

### 1. Ruby-native checks (Gemfile + Rakefile)

- **Gemfile**: add `gem 'html-proofer'` in a `group :test do ... end` block — validates the built `_site/` for broken internal/external links, missing images, and missing alt text.
- **New `Rakefile`** at repo root with tasks:
  - `rake build` → `bundle exec jekyll build`
  - `rake test:frontmatter` → runs a new front-matter validator script
  - `rake test:html` → depends on `build`, then runs `HTMLProofer.check_directory("./_site", ...)`
  - `rake test` → runs `test:frontmatter` + `test:html`
- **New `script/validate_front_matter.rb`**: reads every `_posts/*.md`, parses the YAML front matter, and checks for the required keys documented in [AGENTS.md:30-42](AGENTS.md:30) (`layout`, `title`, `date`, `categories`, `tags`, `image`, `image2`), plus confirms `image`/`image2` paths exist on disk under `assets/article_images/`. Exits non-zero with a clear per-file message on any violation.

### 2. Node-based checks (Sass + JS)

New `package.json` (devDependencies only, no runtime deps):
- `stylelint` + `stylelint-config-standard` + `stylelint-config-standard-scss` + `postcss-sass` (custom syntax for indented `.sass`) + `postcss-scss` (for the one `.scss` partial)
- `eslint` (flat config, `eslint.config.js`) targeting `assets/js/index.js` with browser globals

New config files:
- `.stylelintrc.json` — `overrides` array: `**/*.scss` → `postcss-scss` syntax + `stylelint-config-standard-scss`; `**/*.sass` → `postcss-sass` syntax + `stylelint-config-standard`. Lint globs limited to `css/main.sass` and `_sass/*.scss` (the `_sass/bourbon/**` vendor library and the dead `*.scss__` files are naturally excluded by extension).
- `eslint.config.js` — `eslint:recommended` + browser env, scoped to `assets/js/index.js`.
- `package.json` scripts: `lint:css` (stylelint) and `lint:js` (eslint).
- `.gitignore`: add `node_modules/`.

**Execution note**: since these linters are new to already-written code, the first run will likely surface pre-existing style nits. Per the "surgical changes" principle, I will not mass-reformat the whole codebase to satisfy a new linter — I'll triage the first run's output and either fix genuine small issues (expected to be few, given the tiny surface) or scope down specific rules that conflict with intentional existing style, rather than rewriting files wholesale.

### 3. CI wiring (`.github/workflows/jekyll-build-deploy-test.yml`)

- **New `lint` job** (parallel, no dependency on `build`): checkout → setup Ruby (bundler-cache) → setup Node 20 (npm cache) → `npm ci` → `bundle exec rake test:frontmatter` → `npm run lint:css` → `npm run lint:js`.
- **`build` job**: add a step right after "Build with Jekyll" that runs `bundle exec rake test:html` (reuses the already-built `_site/`, no duplicate build).
- **`deploy` and `surge` jobs**: change `needs: build` → `needs: [build, lint]` so any lint/test failure blocks deployment, same as a build failure does today.

### 4. Documentation

- Update [AGENTS.md](AGENTS.md) "Commands" section and the "No local lint..." line to document the new commands:
  ```bash
  bundle exec rake test          # front matter + html-proofer
  npm run lint:css               # stylelint
  npm run lint:js                # eslint
  ```
- Update [CLAUDE.md](CLAUDE.md)'s reference to "No lint, typecheck, or test suite exists locally" to match.

## Files to add/modify

- Add: `Rakefile`, `script/validate_front_matter.rb`, `package.json`, `.stylelintrc.json`, `eslint.config.js`
- Modify: `Gemfile`, `.gitignore`, `.github/workflows/jekyll-build-deploy-test.yml`, `AGENTS.md`, `CLAUDE.md`

## Verification

1. `bundle install` succeeds and pulls in `html-proofer`.
2. `npm install` succeeds and pulls in stylelint/eslint.
3. `bundle exec rake test:frontmatter` passes against the existing 14 posts (or reports real, fixable issues).
4. `bundle exec jekyll build && bundle exec rake test:html` passes against the built `_site/` (or reports real broken links/images to fix).
5. `npm run lint:css` and `npm run lint:js` run clean (after any necessary rule tuning / small fixes).
6. Push a throwaway branch/PR (or inspect the workflow YAML for correctness) to confirm the new `lint` job and the `test:html` step are wired correctly and `deploy`/`surge` correctly wait on both `build` and `lint`.
