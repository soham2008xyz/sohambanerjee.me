#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Ensure Node matches .nvmrc for lint tooling (nvm on snapshot VMs; nodesource in Dockerfile image)
if [ -f .nvmrc ]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  nvm install
  nvm use
fi

bundle config set --local path 'vendor/bundle'
bundle install --jobs 4 --retry 3
npm ci
