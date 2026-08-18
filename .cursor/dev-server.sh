#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
  eval "$(rbenv init - bash)"
fi

if [ -f .nvmrc ]; then
  required_major="$(tr -d '[:space:]' < .nvmrc | cut -d. -f1)"
  current_major="$(node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1 || true)"
  if [ "$current_major" != "$required_major" ]; then
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    nvm install
    nvm use
  fi
fi

exec bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload
