#!/bin/bash
#
# scaffold-expo.sh — Clone the expo-boilerplate and customize it for a new project
#
# Usage:
#   scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]
#
# Example:
#   scaffold-expo.sh my-cool-app "My Cool App" com.example.mycoolapp http://my-cool-app-backend.test

set -euo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────

SLUG="${1:?Usage: scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]}"
APP_NAME="${2:?Usage: scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]}"
BUNDLE_ID="${3:?Usage: scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]}"
API_URL="${4:-http://localhost:3000}"

REPO="https://github.com/robin7331/expo-boilerplate.git"

# ── Clone ────────────────────────────────────────────────────────────────────

if [ -d "$SLUG" ]; then
  echo "Error: directory '$SLUG' already exists"
  exit 1
fi

echo "Cloning expo-boilerplate into $SLUG/..."
git clone --depth 1 "$REPO" "$SLUG"
rm -rf "$SLUG/.git"

cd "$SLUG"

# ── Replace placeholders ────────────────────────────────────────────────────

echo "Customizing for '$APP_NAME'..."

# app.config.ts
sed -i '' "s|Expo Boilerplate|${APP_NAME}|g" app.config.ts
sed -i '' "s|expo-boilerplate|${SLUG}|g" app.config.ts
sed -i '' "s|com.example.expoboilerplate|${BUNDLE_ID}|g" app.config.ts

# env.ts
sed -i '' "s|http://localhost:3000|${API_URL}|g" env.ts

# package.json — update name field
sed -i '' "s|\"name\": \"expo-boilerplate\"|\"name\": \"${SLUG}\"|" package.json

# ── Install dependencies ────────────────────────────────────────────────────

echo "Installing dependencies..."
npm install

# ── Install agent skills (best-effort) ──────────────────────────────────────

echo "Installing agent skills..."
npx skills add vercel-labs/agent-skills@react-native-guidelines -y 2>/dev/null || true
npx skills add heroui/heroui-native-skill@heroui-native -y 2>/dev/null || true
npx skills add nicepkg/uniwind-skill@uniwind -y 2>/dev/null || true
npx skills add vercel-labs/agent-skills@react-best-practices -y 2>/dev/null || true
npx skills add vercel-labs/skills@find-skills -g -y 2>/dev/null || true

# ── Git init ─────────────────────────────────────────────────────────────────

echo "Initializing git repository..."
git init
git add -A
git commit -m "Initial scaffold via create-expo-app skill"

echo ""
echo "Done! cd $SLUG && npm start"
