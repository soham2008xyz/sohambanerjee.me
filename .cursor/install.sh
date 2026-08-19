#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Ensure Node matches .nvmrc for lint tooling when the base image does not already provide it
if [ -f .nvmrc ]; then
  required_major="$(tr -d '[:space:]' < .nvmrc | cut -d. -f1)"
  current_major="$(node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1 || true)"
  if [ "$current_major" != "$required_major" ]; then
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
      nvm_install_script="$(mktemp)"
      curl -fsSL -o "$nvm_install_script" https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh
      bash "$nvm_install_script"
      rm -f "$nvm_install_script"
    fi
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    nvm install
    nvm use
  fi
fi

bundle config set --local path 'vendor/bundle'
bundle install --jobs 4 --retry 3
npm ci
