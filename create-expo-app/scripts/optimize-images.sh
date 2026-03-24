#!/bin/bash
#
# optimize-images.sh — Compress and generate resolution variants for app images
#
# What it does:
#   1. Resizes oversized images to sensible @3x maximums
#   2. Generates @1x / @2x / @3x variants (React Native picks per device density)
#   3. Compresses ALL app PNGs with pngquant (~50-80% savings)
#
# Prerequisites:
#   brew install pngquant
#
# Usage:
#   ./scripts/optimize-images.sh            # run optimization
#   ./scripts/optimize-images.sh --dry-run  # preview without changing files
#
# Customization:
#   Edit the "Main" section at the bottom to add your project's image paths.
#   The helpers (compress_png, generate_variants) work with any PNG.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# ── Prerequisites ────────────────────────────────────────────────────────────

if ! command -v pngquant &>/dev/null; then
  echo "Error: pngquant is required. Install with: brew install pngquant"
  exit 1
fi

# ── Helpers ──────────────────────────────────────────────────────────────────

total_before=0
total_after=0
files_processed=0

fmt() { # bytes -> human-readable
  local b=$1
  if (( b >= 1048576 )); then
    printf "%.1fM" "$(echo "scale=1; $b / 1048576" | bc)"
  else
    printf "%dK" "$(( b / 1024 ))"
  fi
}

get_width() { sips -g pixelWidth "$1" 2>/dev/null | awk '/pixelWidth/{print $2}'; }
get_height() { sips -g pixelHeight "$1" 2>/dev/null | awk '/pixelHeight/{print $2}'; }

# Compress a single PNG with pngquant (lossy, high quality)
compress_png() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local before; before=$(stat -f%z "$file")

  if $DRY_RUN; then
    total_before=$(( total_before + before ))
    total_after=$(( total_after + before * 40 / 100 ))
    printf "  [dry] %s: %s -> ~%s\n" "$(basename "$file")" "$(fmt $before)" "$(fmt $(( before * 40 / 100 )))"
    return
  fi

  pngquant --quality=65-80 --speed 1 --strip --force --output "$file" -- "$file" 2>/dev/null || true

  local after; after=$(stat -f%z "$file")
  total_before=$(( total_before + before ))
  total_after=$(( total_after + after ))
  files_processed=$(( files_processed + 1 ))

  local saved=$(( before - after ))
  if (( saved > 0 )); then
    printf "  OK %s: %s -> %s (%d%% smaller)\n" \
      "$(basename "$file")" "$(fmt $before)" "$(fmt $after)" "$(( saved * 100 / before ))"
  else
    printf "  -- %s: already optimized\n" "$(basename "$file")"
  fi
}

# Generate @1x/@2x/@3x from a source image.
# $1 = file path, $2 = max pixel width for @3x variant
generate_variants() {
  local file="$1" max_w3x="$2"
  [[ -f "$file" ]] || return 0

  local dir base ext
  dir=$(dirname "$file")
  ext="${file##*.}"
  base=$(basename "$file" ".$ext")

  # Skip if variants already exist
  if [[ -f "${dir}/${base}@2x.${ext}" ]]; then
    echo "  -- ${base}: variants already exist, skipping"
    return
  fi

  local width height
  width=$(get_width "$file")
  height=$(get_height "$file")

  local w3x=$width
  if (( width > max_w3x )); then
    w3x=$max_w3x
  fi
  local w2x=$(( w3x * 2 / 3 ))
  local w1x=$(( w3x / 3 ))

  if $DRY_RUN; then
    printf "  [dry] %s: %dx%d -> @3x(%dpx) @2x(%dpx) @1x(%dpx)\n" \
      "$base" "$width" "$height" "$w3x" "$w2x" "$w1x"
    return
  fi

  local file_3x="${dir}/${base}@3x.${ext}"
  if (( width > max_w3x )); then
    sips --resampleWidth "$w3x" "$file" --out "$file_3x" >/dev/null 2>&1
  else
    cp "$file" "$file_3x"
  fi

  local file_2x="${dir}/${base}@2x.${ext}"
  sips --resampleWidth "$w2x" "$file_3x" --out "$file_2x" >/dev/null 2>&1

  sips --resampleWidth "$w1x" "$file" --out "$file" >/dev/null 2>&1

  printf "  OK %s: @3x(%dpx) @2x(%dpx) @1x(%dpx)\n" "$base" "$w3x" "$w2x" "$w1x"
}

# ── Main ─────────────────────────────────────────────────────────────────────
#
# Customize the sections below for your project's images.
# Examples:
#
#   generate_variants "$PROJECT_ROOT/assets/images/hero.png" 1290
#   compress_png "$PROJECT_ROOT/assets/images/hero.png"

$DRY_RUN && echo "DRY RUN — no files will be modified" && echo ""

echo "=== Step 1: Compress app icon PNGs ==="
echo ""

for f in "$PROJECT_ROOT"/assets/images/icon.png \
         "$PROJECT_ROOT"/assets/images/favicon.png \
         "$PROJECT_ROOT"/assets/images/android-icon-foreground.png \
         "$PROJECT_ROOT"/assets/images/android-icon-background.png \
         "$PROJECT_ROOT"/assets/images/android-icon-monochrome.png; do
  compress_png "$f"
done

# ── Add your project images below ────────────────────────────────────────────
#
# echo ""
# echo "=== Step 2: Generate resolution variants ==="
# echo ""
# generate_variants "$PROJECT_ROOT/assets/images/onboarding/slide-1.png" 1290
#
# echo ""
# echo "=== Step 3: Compress feature images ==="
# echo ""
# for f in "$PROJECT_ROOT"/assets/images/features/*.png; do
#   compress_png "$f"
# done

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "========================================================"
if $DRY_RUN; then
  echo "  DRY RUN ESTIMATE"
else
  echo "  OPTIMIZATION COMPLETE"
fi
if (( total_before > 0 )); then
  saved=$(( total_before - total_after ))
  pct=$(( saved * 100 / total_before ))
  echo "  Before: $(fmt $total_before)"
  echo "  After:  $(fmt $total_after)"
  echo "  Saved:  $(fmt $saved) (${pct}%)"
  $DRY_RUN || echo "  Files:  $files_processed compressed"
fi
echo "========================================================"
