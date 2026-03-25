#!/bin/bash
#
# scaffold-laravel.sh — Create a Laravel backend with React starter kit
#
# Usage:
#   scaffold-laravel.sh <backend-slug> [--sanctum] [--pulse] [--telescope]
#
# Example:
#   scaffold-laravel.sh my-app-backend --sanctum --pulse --telescope

set -euo pipefail

# ── Args ─────────────────────────────────────────────────────────────────────

BACKEND_SLUG="${1:?Usage: scaffold-laravel.sh <backend-slug> [--sanctum] [--pulse] [--telescope]}"
shift

SANCTUM=false
PULSE=false
TELESCOPE=false

for arg in "$@"; do
  case "$arg" in
    --sanctum) SANCTUM=true ;;
    --pulse) PULSE=true ;;
    --telescope) TELESCOPE=true ;;
  esac
done

# ── Create Laravel app ──────────────────────────────────────────────────────

if [ -d "$BACKEND_SLUG" ]; then
  echo "Error: directory '$BACKEND_SLUG' already exists"
  exit 1
fi

# Ensure laravel CLI is available
if ! command -v laravel &>/dev/null; then
  echo "Installing Laravel installer..."
  composer global require laravel/installer
fi

echo "Creating Laravel app '$BACKEND_SLUG' with React starter kit..."
laravel new "$BACKEND_SLUG" --using=react

cd "$BACKEND_SLUG"

# ── Sanctum API ─────────────────────────────────────────────────────────────

if $SANCTUM; then
  echo "Installing Sanctum API scaffolding..."
  php artisan install:api
fi

# ── Pulse ────────────────────────────────────────────────────────────────────

if $PULSE; then
  echo "Installing Laravel Pulse..."
  composer require laravel/pulse
  php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
fi

# ── Telescope ────────────────────────────────────────────────────────────────

if $TELESCOPE; then
  echo "Installing Laravel Telescope..."
  composer require laravel/telescope
  php artisan telescope:install
fi

# ── Migrate ──────────────────────────────────────────────────────────────────

if $PULSE || $TELESCOPE || $SANCTUM; then
  echo "Running migrations..."
  php artisan migrate
fi

# ── Laravel Boost ────────────────────────────────────────────────────────────

echo "Installing Laravel Boost..."
composer require --dev laravel/boost

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "Laravel scaffolding complete: $BACKEND_SLUG/"
echo "Remaining steps (handled by agent): AuthController, routes, seeder, sidebar, boost:install, API specs"
