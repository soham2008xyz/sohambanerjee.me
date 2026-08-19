#!/usr/bin/env bash
# Source before npm or Ruby commands in interactive shells: source .cursor/env.sh

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  _cursor_env_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "${_cursor_env_dir}/../.nvmrc" ]; then
    nvm use --silent 2>/dev/null || nvm use
  fi
fi

if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
  eval "$(rbenv init - bash)"
fi
