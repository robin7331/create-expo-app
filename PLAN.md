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
- `scaffold-laravel.sh` — runs `laravel new`, `php artisan install:api`, installs Pulse/Telescope/Boost
- Agent only handles: DESIGN.md from vibe, global.css colors, CLAUDE.md append, README.md generation
- Auth and IAP handled by auto-invoking `/add-auth` and `/add-iap` scripts

**Removed files (now in boilerplate):**
- `references/wiring-guide.md` — config templates baked into boilerplate
- `references/auth-guide.md` — auth files in `templates/auth/`
- `references/CLAUDE-TEMPLATE.md` — boilerplate ships with CLAUDE.md, agent appends to it
- `scripts/optimize-images.sh` — lives in boilerplate
- `scripts/sync-production-env.sh` — lives in boilerplate

**Remaining files:**
- `SKILL.md` — orchestration (questions → scripts → agents)
- `scripts/scaffold-expo.sh` — clone + customize boilerplate
- `scripts/scaffold-laravel.sh` — Laravel CLI commands
- `references/laravel-guide.md` — code templates for Laravel modifications
- `references/DESIGN-TEMPLATE.md` — structure reference for DESIGN.md generation

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
  - scaffold-laravel.sh creates the Laravel app with correct flags
  - Agent creates AuthController, routes, seeder correctly
  - Agent wires Pulse/Telescope into sidebar
  - Agent generates docs/api-specs.md from actual routes
  - Cross-project references work (CLAUDE.md in both projects)
  - Login works: Expo app → Laravel API → token → authenticated

### Medium Priority

- [ ] **Create a Laravel boilerplate repo** — same pattern as expo-boilerplate. Move deterministic Laravel setup (AuthController, API routes, seeder, production safety, companion-app guideline) into a cloneable repo with local skills. Would further reduce LLM context usage for Laravel scaffolding.

- [ ] **DESIGN-TEMPLATE.md redundancy** — the boilerplate already ships with DESIGN.md. The template is only used as a structural reference for the agent when regenerating from vibe. Consider whether the agent can just read the existing DESIGN.md and update values instead of referencing a separate template.

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
