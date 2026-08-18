#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# shellcheck source=/dev/null
source .cursor/env.sh

exec bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload
