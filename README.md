<p align="center">
  <img src="assets/images/tn_logo.jpg" alt="The Nonconformist logo" width="96" />
</p>

<h1 align="center">The Nonconformist</h1>

<p align="center">Personal blog by Soham Banerjee, built with Jekyll.</p>

<p align="center"><a href="https://sohambanerjee.me">sohambanerjee.me</a></p>

---

A static Jekyll site with no Node.js build step. Styling is Sass (indented syntax) built on the [Bourbon](https://www.bourbon.io/) mixin/grid library, hosted on GitHub Pages with a Surge.sh staging mirror.

## Stack

- Ruby 3.2.3, Jekyll (via the `github-pages` gem), Bundler
- Sass (`.sass`, indented syntax), Bourbon
- Liquid templating

## Getting started

```bash
bundle install
bundle exec jekyll serve
```

The site is served at `http://localhost:4000`.

To produce a static build in `_site/`:

```bash
bundle exec jekyll build
```

> [!NOTE]
> There's no local lint, typecheck, or test suite. CI runs Lighthouse against the deployed staging site rather than the local build.

## Project structure

```text
_layouts/    default → page/post layout chain
_includes/   head, header, footer, and shared partials
_posts/      blog entries (YYYY-MM-DD-slug.md)
_sass/       Sass partials (base, layout, syntax-highlighting)
css/main.sass  Sass entry point
assets/      images and other static files
```

See [AGENTS.md](AGENTS.md) for post front matter conventions and other contributor notes.

## Deployment

Pushing to `master` runs the GitHub Actions pipeline: `build` fans out to `deploy` (GitHub Pages) and `surge` (Surge.sh staging), then `test` runs Lighthouse CI against the staging URL. The production domain is set via `CNAME`.
