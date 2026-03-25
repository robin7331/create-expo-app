#!/bin/bash
#
# scaffold-laravel.sh — Clone the laravel-boilerplate and customize it for a new project
#
# Usage:
#   scaffold-laravel.sh <backend-slug> <app-slug>
#
# Example:
#   scaffold-laravel.sh my-app-backend my-app

set -euo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────

BACKEND_SLUG="${1:?Usage: scaffold-laravel.sh <backend-slug> <app-slug>}"
APP_SLUG="${2:?Usage: scaffold-laravel.sh <backend-slug> <app-slug>}"

REPO="https://github.com/robin7331/expo-boilerplate-laravel-backend.git"

# ── Clone ────────────────────────────────────────────────────────────────────

if [ -d "$BACKEND_SLUG" ]; then
  echo "Error: directory '$BACKEND_SLUG' already exists"
  exit 1
fi

echo "Cloning laravel-boilerplate into $BACKEND_SLUG/..."
git clone --depth 1 "$REPO" "$BACKEND_SLUG"
rm -rf "$BACKEND_SLUG/.git"

cd "$BACKEND_SLUG"

# ── Replace placeholders ────────────────────────────────────────────────────

echo "Customizing for '$BACKEND_SLUG'..."

# Companion app slug in guideline
sed -i '' "s|__APP_SLUG__|${APP_SLUG}|g" .ai/guidelines/companion-app.md

# ── Set up environment ───────────────────────────────────────────────────────

echo "Setting up environment..."
cp .env.example .env

# Set APP_NAME and APP_URL in .env
sed -i '' "s|APP_NAME=Laravel|APP_NAME=${BACKEND_SLUG}|" .env
sed -i '' "s|APP_URL=http://localhost|APP_URL=http://${BACKEND_SLUG}.test|" .env

# ── Install dependencies ────────────────────────────────────────────────────

echo "Installing PHP dependencies..."
composer install --no-interaction --quiet

echo "Installing Node dependencies..."
npm install --silent

# ── Laravel setup ────────────────────────────────────────────────────────────

echo "Generating app key..."
php artisan key:generate --no-interaction

echo "Running migrations..."
php artisan migrate --no-interaction

# ── Laravel Boost ────────────────────────────────────────────────────────────

echo "Running boost:install..."
php artisan boost:install --no-interaction

# ── Git init ─────────────────────────────────────────────────────────────────

echo "Initializing git repository..."
git init
git add -A
git commit -m "Initial scaffold via create-expo-app skill"

echo ""
echo "Done! cd $BACKEND_SLUG"
