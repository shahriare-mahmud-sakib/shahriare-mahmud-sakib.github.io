#!/usr/bin/env bash
set -euo pipefail

echo "1. Validating YAML, front matter, and page routes"
ruby scripts/check_site.rb

echo
echo "2. Building the complete Jekyll website"
bundle exec jekyll build --strict_front_matter

echo
echo "SUCCESS: the repository is safe to commit and push."
