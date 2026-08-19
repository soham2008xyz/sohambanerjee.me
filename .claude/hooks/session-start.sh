#!/bin/bash
# SessionStart hook for Claude Code on the web: installs the gems and npm
# packages needed to run `bundle exec jekyll build`, `bundle exec rake test`,
# `npm run lint:css`, and `npm run lint:js` during the session.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Ruby is pinned via .ruby-version (3.2.6); make sure rbenv's shims (which
# respect that pin) are on PATH, both for this script and for the rest of
# the session.
if [ -d "$HOME/.rbenv" ] || [ -d /opt/rbenv ]; then
  export PATH="/opt/rbenv/shims:$HOME/.rbenv/shims:$PATH"
  echo "export PATH=\"/opt/rbenv/shims:\$HOME/.rbenv/shims:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# The container has no locale generated, which leaves Ruby's default
# external encoding at US-ASCII and breaks reading UTF-8 post content
# (rake test:frontmatter, jekyll build). C.UTF-8 is always available.
export LANG=C.UTF-8
echo 'export LANG=C.UTF-8' >> "$CLAUDE_ENV_FILE"

bundle config set --local path 'vendor/bundle'
bundle install --jobs 4 --retry 3

npm install
