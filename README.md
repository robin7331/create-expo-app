# create-expo-app

An opinionated [Agent Skill](https://agentskills.io/) for **Expo + Laravel** developers. Scaffold a production-ready React Native app — optionally paired with a Laravel backend — in one command.

Built for AI coding agents (Claude Code, Cursor, Gemini CLI, Codex, and more).

## Why Opinionated?

This skill makes choices so you don't have to. It's built for developers who love **Laravel** on the backend and **Expo** on the frontend. If that's your stack, everything is wired up and ready to ship. If you don't need a backend, the Expo app stands on its own.

## What It Does

### Expo App (always)

- **Expo 55** + React Native 0.83 + TypeScript (strict)
- **Tailwind CSS v4** via Uniwind + **HeroUI Native** component library
- **Zustand** + **React Query** + **MMKV** for state and storage
- **Expo Router** file-based routing
- **Reanimated** + **Gesture Handler** + **Bottom Sheet**
- **Jest** + **React Testing Library** + **Prettier**
- Full **EAS Build** config (dev / preview / production)
- **CLAUDE.md**, **DESIGN.md**, and **README.md** included
- **OfflineBanner** component with NetInfo
- Utility scripts (image optimization, env syncing)
- Project-level agent skills auto-installed
- Local skills: `/add-auth`, `/add-iap` — composable, invoke anytime

### Laravel Backend (optional)

- **Laravel with React starter kit** — Inertia + React admin dashboard + Fortify auth
- **Sanctum API tokens** — mobile app auth that works out of the box
- **Pulse** (monitoring) + **Telescope** (debugging) wired into the admin sidebar
- **Laravel Boost** — AI-powered guidelines, skills, and MCP servers
- **`docs/api-specs.md`** — single source of truth for the API contract
- **Working login** — launch the simulator, sign in with `test@example.com` / `password`
- **Cross-project AI awareness** — say "check the backend" or "create an issue in the app" and the AI knows exactly where to go

### Optional Integrations

- **RevenueCat** — in-app purchases and subscriptions (via `/add-iap` skill)
- **Sanctum Auth** — full auth flow with login screen (via `/add-auth` skill)

## Architecture

The skill separates concerns into three layers:

1. **Chat context** — gather parameters from the user (questions, confirmation)
2. **Shell scripts** — deterministic scaffolding (clone boilerplate, sed replacements, CLI commands)
3. **Agents** — intelligent generation (DESIGN.md from vibe, CLAUDE.md customization, global.css colors)

The Expo app is cloned from [robin7331/expo-boilerplate](https://github.com/robin7331/expo-boilerplate) — a standalone, runnable boilerplate repo. The skill customizes it post-clone.

## Installation

```bash
npx skills add robin7331/create-expo-app -g -y
```

## Usage

Invoke the skill in your agent:

```
/create-expo-app
```

Or just ask naturally:

```
Create a new Expo app
```
```
Scaffold a React Native project with a Laravel backend
```
```
Start a new mobile app called "My App"
```

## Interactive Questions

1. **App name** — e.g., "My Cool App"
2. **Bundle ID** — suggested from the name, or specify your own
3. **Laravel backend?** — scaffolds a companion Laravel project
   - Backend name (default: `{slug}-backend`)
   - Sanctum API tokens for mobile auth (default: yes)
   - Pulse & Telescope (default: both)
4. **In-app purchases?** — installs RevenueCat if yes
5. **Design vibe** — generates a color palette, tokens, and brand voice

Then it scaffolds everything and you're ready to `npm start`.

## What Gets Created

### Without Laravel Backend

```
my-cool-app/
├── src/
│   ├── app/
│   │   ├── _layout.tsx       # Provider hierarchy (wired up)
│   │   └── index.tsx          # Starter screen
│   ├── features/              # Feature modules go here
│   ├── components/
│   │   └── offline-banner.tsx # NetInfo offline indicator
│   ├── hooks/
│   ├── lib/
│   │   ├── cn.ts              # clsx + tailwind-merge
│   │   ├── storage.ts         # MMKV wrapper
│   │   └── query.tsx          # React Query + NetInfo
│   └── global.css             # Tailwind + design tokens
├── scripts/
│   ├── add-auth.sh            # Invoke via /add-auth
│   ├── add-iap.sh             # Invoke via /add-iap
│   ├── sync-production-env.sh
│   └── optimize-images.sh
├── templates/auth/            # Auth file templates
├── .claude/skills/            # Local agent skills
│   ├── add-auth/SKILL.md
│   └── add-iap/SKILL.md
├── app.config.ts
├── eas.json
├── env.ts
├── metro.config.js
├── tsconfig.json
├── CLAUDE.md
├── DESIGN.md
└── README.md
```

### With Laravel Backend

Same as above, plus auth files added automatically:

```
my-cool-app/
├── src/
│   ├── app/
│   │   ├── _layout.tsx        # Auth-aware with AuthGuard
│   │   ├── index.tsx
│   │   └── login.tsx          # Login screen (works out of the box)
│   ├── features/
│   │   └── auth/              # Full auth client
│   │       ├── api.ts         # login / register / logout / getUser
│   │       ├── store.ts       # Zustand + MMKV auth state
│   │       └── types.ts       # User, AuthResponse types
│   ├── lib/
│   │   ├── api.ts             # Fetch wrapper with Bearer token
│   │   └── ...
│   └── ...
└── ...

my-cool-app-backend/           # Laravel app
├── app/Http/Controllers/Api/V1/
│   └── AuthController.php     # Sanctum token auth
├── routes/api.php             # /api/v1/auth/* endpoints
├── .ai/guidelines/
│   └── companion-app.md       # AI cross-reference to Expo app
├── docs/api-specs.md          # API contract (source of truth)
├── AGENTS.md                  # Generated by Laravel Boost
├── CLAUDE.md                  # Generated by Laravel Boost
└── ...
```

## Skill Structure

```
create-expo-app/
├── SKILL.md                           # Interactive workflow (v3.0)
├── scripts/
│   ├── scaffold-expo.sh               # Clone boilerplate + sed placeholders
│   └── scaffold-laravel.sh            # laravel new + artisan + composer
└── references/
    ├── laravel-guide.md               # Laravel code modification templates
    └── DESIGN-TEMPLATE.md             # DESIGN.md structure reference
```

## License

MIT
