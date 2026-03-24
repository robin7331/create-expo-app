#!/bin/bash
# Pulls production environment variables from EAS and writes them to .env.production
set -euo pipefail

ENV_FILE=".env.production"

echo "Syncing production env from EAS..."
raw=$(npx eas-cli env:list --environment production --include-sensitive 2>/dev/null)

# Parse KEY=VALUE lines (skip header/blank lines)
echo "$raw" | grep '^EXPO_PUBLIC_' > "$ENV_FILE"

echo "Wrote $(wc -l < "$ENV_FILE" | tr -d ' ') variables to $ENV_FILE"
