#!/bin/bash
#
# scaffold-expo.sh — Clone the expo-boilerplate and customize it for a new project
#
# Usage:
#   scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url] [ats-http-domain]
#
# Example:
#   scaffold-expo.sh my-cool-app "My Cool App" com.example.mycoolapp http://my-cool-app-backend.test my-cool-app-backend.test

set -euo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────

SLUG="${1:?Usage: scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]}"
APP_NAME="${2:?Usage: scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]}"
BUNDLE_ID="${3:?Usage: scaffold-expo.sh <slug> <app-name> <bundle-id> [api-url]}"
API_URL="${4:-http://localhost:3000}"
ATS_HTTP_DOMAIN="${5:-}"

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

# app.config.ts — add ATS exception for insecure HTTP domain (iOS)
if [ -n "$ATS_HTTP_DOMAIN" ]; then
  echo "Adding ATS exception for $ATS_HTTP_DOMAIN..."
  perl -i -pe "s|(ITSAppUsesNonExemptEncryption: false,)|\$1\n      NSAppTransportSecurity: {\n        NSExceptionDomains: {\n          '${ATS_HTTP_DOMAIN}': {\n            NSExceptionAllowsInsecureHTTPLoads: true,\n          },\n        },\n      },|" app.config.ts
fi

# ── Install dependencies ────────────────────────────────────────────────────

echo "Installing dependencies..."
npm install

# ── Install agent skills (best-effort, quiet) ────────────────────────────────

echo "Installing agent skills..."

# Each entry: "display_name|command|flags"
SKILLS=(
  "heroui-native|https://github.com/heroui-inc/heroui --skill heroui-native|"
  "uniwind|uni-stack/uniwind|"
  "vercel-react-native-skills|https://github.com/vercel-labs/agent-skills --skill vercel-react-native-skills|"
  "react-native-architecture|https://github.com/wshobson/agents --skill react-native-architecture|"
  "apple-appstore-reviewer|https://github.com/github/awesome-copilot --skill apple-appstore-reviewer|"
)

installed=0
failed=0

for entry in "${SKILLS[@]}"; do
  IFS='|' read -r name cmd flags <<< "$entry"
  if npx skills add $cmd $flags -y >/dev/null 2>&1; then
    echo "  ✓ $name"
    ((installed++))
  else
    echo "  ✗ $name (skipped)"
    ((failed++))
  fi
done

echo "  ${installed} installed, ${failed} skipped"

# ── Git init ─────────────────────────────────────────────────────────────────

echo "Initializing git repository..."
git init
git add -A
git commit -m "Initial scaffold via create-expo-app skill"

echo ""
echo "Done! cd $SLUG && npm start"
