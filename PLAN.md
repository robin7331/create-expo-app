# create-expo-app v3.0 — Plan

## Design Principle

Separate **deterministic work** (shell scripts, template files) from **intelligent work** (LLM agents) and **interactive work** (chat context). The LLM should never waste tokens on things a shell script can do.

```
Chat Context (questions) → Shell Scripts (clone, sed, install) → Agents (DESIGN.md, CLAUDE.md, colors)
```

## What Was Done

### 1. Created `robin7331/expo-boilerplate` repo

A standalone, runnable Expo boilerplate that works out of the box (`git clone` → `npm install` → `npm run ios`).

**Contents:**
- Expo 55 / React Native 0.83 / React 19.2 / TypeScript (strict)
- Tailwind v4 + Uniwind + HeroUI Native
- Zustand + React Query + TanStack Form + Zod
- MMKV + NitroModules
- Reanimated + Gesture Handler + Bottom Sheet
- Jest + React Testing Library + Prettier
- Full EAS build config (dev/preview/production)
- OfflineBanner component wired into root layout
- CLAUDE.md with stack, patterns, conventions, and DESIGN.md enforcement rules
- DESIGN.md with default neutral OKLCH color palette matching global.css
- README.md with setup, commands, and stack overview
- Utility scripts (optimize-images.sh, sync-production-env.sh)
- .npmrc with legacy-peer-deps (react-test-renderer compat)
- .env.example with documented optional vars

**Placeholder values for customization (sed-replaceable):**
- `Expo Boilerplate` → app name
- `expo-boilerplate` → slug
- `com.example.expoboilerplate` → bundle ID
- `http://localhost:3000` → API URL

### 2. Created local skills in the boilerplate

**`/add-auth`** — Adds Sanctum API token authentication:
- `templates/auth/` contains all static auth files
- `scripts/add-auth.sh` copies them into `src/`
- Files: api.ts (fetch wrapper), auth feature (types, api, store), login.tsx, auth-enabled _layout.tsx
- `.claude/skills/add-auth/SKILL.md` — skill definition

**`/add-iap`** — Adds RevenueCat in-app purchases:
- `scripts/add-iap.sh` runs npm install + installs RevenueCat skill
- `.claude/skills/add-iap/SKILL.md` — skill definition

### 3. Rewrote `create-expo-app` skill (v2 → v3)

**Before (v2):** 680 lines of inline commands in SKILL.md. The LLM ran `npx create-expo-app`, deleted boilerplate, installed 22+ packages, wrote 15+ config files, all within chat context.

**After (v3):** ~200 lines of orchestration in SKILL.md.
- `scaffold-expo.sh` — clones boilerplate, sed-replaces placeholders, npm install, installs agent skills, git init
- `scaffold-laravel.sh` — clones laravel-boilerplate, sed-replaces placeholders, composer/npm install, boost:install, git init
- Agent only handles: DESIGN.md from vibe, global.css colors, CLAUDE.md append, README.md generation, docs/api-specs.md
- Auth and IAP handled by auto-invoking `/add-auth` and `/add-iap` scripts

**Removed files (now in boilerplate):**
- `references/wiring-guide.md` — config templates baked into boilerplate
- `references/auth-guide.md` — auth files in `templates/auth/`
- `references/CLAUDE-TEMPLATE.md` — boilerplate ships with CLAUDE.md, agent appends to it
- `references/laravel-guide.md` — code templates now in laravel-boilerplate as skills/scripts/templates
- `references/DESIGN-TEMPLATE.md` — agent updates the existing DESIGN.md from the boilerplate instead
- `scripts/optimize-images.sh` — lives in boilerplate
- `scripts/sync-production-env.sh` — lives in boilerplate

**Remaining files:**
- `SKILL.md` — orchestration (questions → scripts → agents)
- `scripts/scaffold-expo.sh` — clone + customize expo-boilerplate
- `scripts/scaffold-laravel.sh` — clone + customize laravel-boilerplate

---

## What Still Needs To Be Done

### High Priority

- [ ] **Test the full skill flow end-to-end** — invoke `/create-expo-app` in a fresh directory and verify:
  - scaffold-expo.sh clones and customizes correctly
  - Agent generates DESIGN.md from vibe
  - Agent updates global.css colors to match
  - Agent appends backend section to CLAUDE.md (if Laravel)
  - Agent generates README.md
  - /add-auth runs correctly (if Sanctum)
  - /add-iap runs correctly (if IAP)
  - Final app runs with `npm run ios`

- [ ] **Test the Laravel flow end-to-end** — verify:
  - scaffold-laravel.sh clones and customizes correctly
  - add-sanctum-api.sh installs Sanctum, copies AuthController + routes, migrates
  - add-pulse-telescope.sh installs Pulse/Telescope, wires sidebar
  - Agent generates docs/api-specs.md from actual routes
  - Cross-project references work (companion-app guideline in both projects)
  - Login works: Expo app → Laravel API → token → authenticated

### Medium Priority

- [x] **Create a Laravel boilerplate repo** — `robin7331/expo-boilerplate-laravel-backend`. Laravel 13 + React starter kit with Boost pre-configured. Deterministic setup (production safety, NavFooter, test user seeder, phpunit disables) baked in. Local skills: `/add-sanctum-api` (AuthController, routes, gates, migrate), `/add-pulse-telescope` (install, publish, sidebar wiring). Custom guidelines: `companion-app.md` (`__APP_SLUG__` placeholder), `design-system.md` (enforces DESIGN.md ↔ app.css sync), `skill-development.md` (contributing skills back to the boilerplate). DESIGN.md with full OKLCH palette, typography, component library docs. `scaffold-laravel.sh` rewritten to clone this repo instead of running `laravel new`.

- [x] **DESIGN-TEMPLATE.md redundancy** — removed. The agent now reads the existing DESIGN.md from the boilerplate and updates values based on the user's vibe, instead of generating from a separate template. Both boilerplates (Expo and Laravel) ship with their own DESIGN.md with neutral defaults.

- [x] **Boilerplate contribution workflow** — both boilerplate repos have guidelines explaining how to contribute reusable features back as skills. Only triggers when the user explicitly mentions "the boilerplate" or "the boilerplates". Includes steps for creating the skill, and updating the `create-expo-app` orchestrator if needed.

- [ ] **scaffold-expo.sh portability** — currently uses `sed -i ''` (macOS). Won't work on Linux. Consider using `sed -i` without the empty string arg, or use a different approach for cross-platform compat.

### Low Priority

- [ ] **More local skills for the boilerplate** — potential candidates:
  - `/add-onboarding` — onboarding flow with slides
  - `/add-deep-linking` — associated domains + route handling
  - `/add-push-notifications` — expo-notifications setup
  - `/add-analytics` — analytics integration
  - `/replace-icon` — swap app icon + generate Android adaptive variants

- [ ] **Boilerplate update mechanism** — when the boilerplate evolves, existing projects cloned from it don't get updates. Consider a `/update-boilerplate` skill or changelog.

- [ ] **Testing templates** — the boilerplate has Jest configured but no example tests. Could add a sample test for the storage lib or query provider.
