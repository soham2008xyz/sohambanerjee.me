#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

bundle config set --local path 'vendor/bundle'
bundle install --jobs 4 --retry 3
npm ci
