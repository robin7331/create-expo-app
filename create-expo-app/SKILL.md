---
name: create-expo-app
description: >
  Scaffold a production-ready React Native Expo app with an optional Laravel backend.
  Opinionated stack: Tailwind CSS v4 (Uniwind), HeroUI Native, Zustand, React Query, MMKV,
  full EAS build config, and optional Laravel backend with Sanctum API auth, Pulse, Telescope,
  and Laravel Boost. Use when the user wants to create a new Expo app, start a new React Native
  project, or scaffold a mobile app. Triggers on: "create expo app", "new react native project",
  "scaffold mobile app", "start a new app", "bootstrap expo project".
license: MIT
compatibility: Requires Node.js 18+, npm, and npx. macOS recommended for iOS builds. Laravel backend requires PHP 8.2+ and Composer.
metadata:
  author: robin7331
  version: "2.0.0"
---

# Create Expo App

Scaffold a production-ready React Native Expo app — optionally paired with a Laravel backend — in minutes.

## What This Skill Does

This skill walks you through an interactive setup, then scaffolds a complete Expo project with:

- **Tailwind CSS v4** via Uniwind + **HeroUI Native** component library
- **Zustand** (global state) + **React Query** (server state) + **MMKV** (encrypted storage)
- **Expo Router** file-based routing
- **React Native Reanimated** + **Gesture Handler** + **Bottom Sheet**
- **Jest** + **React Testing Library**
- Full **EAS Build** configuration (dev/preview/production profiles)
- Generated **CLAUDE.md**, **DESIGN.md**, and **README.md**
- Utility scripts for image optimization and env syncing
- Project-level agent skills (uniwind, heroui-native, react-native, etc.)

### Optional Laravel Backend

If selected, the skill also scaffolds a companion Laravel backend alongside the Expo app:

- **Laravel with React starter kit** (Inertia + React admin dashboard + Fortify auth)
- **Sanctum API tokens** for mobile app authentication
- **Laravel Pulse** (monitoring) + **Telescope** (debugging) wired into the admin sidebar
- **Laravel Boost** with custom AI guidelines for cross-project awareness
- **`docs/api-specs.md`** — single source of truth for the API contract
- **Working auth flow** — launch the simulator and log in with `test@example.com` / `password`
- **Cross-project AI agent references** — say "check the backend" or "create an issue in the app" and the AI knows where to go

## Interactive Setup Flow

**IMPORTANT**: Ask these questions ONE AT A TIME. Wait for each answer before proceeding.

### Step 1: Ask Questions

Ask these questions sequentially:

**Q1: App Name**
```
What's your app called?
```
From the answer:
- Derive `slug` by lowercasing and replacing spaces/special chars with hyphens (e.g., "My Cool App" -> "my-cool-app")
- Derive a suggested bundle ID: `com.example.{slug with dots instead of hyphens}`

**Q2: Bundle ID**
```
Bundle ID? [{suggested bundle ID}]
```
Use the suggestion if they press enter / say "yes" / confirm.

**Q3: Laravel Backend**
```
Do you want a Laravel backend for your app? [y/N]
```

If yes, ask these follow-up questions:

**Q3a: Backend Name**
```
Backend project name: {slug}-backend — OK? [Y/n]
```
If they say no, ask for their preferred name. Derive `backendSlug` from this.

**Q3b: Mobile Auth**
```
Use Sanctum API tokens for mobile app authentication? [Y/n]
```

**Q3c: Monitoring Tools**
```
Install Pulse (monitoring) and Telescope (debugging)? [Both/Pulse only/Telescope only/Neither] (default: Both)
```

**Q4: In-App Purchases**
```
Will your app have in-app purchases or subscriptions? [y/N]
```

**Q5: Design Vibe**
```
Describe your app's visual vibe in a few words (e.g., "playful kids app", "minimal fitness tracker", "dark premium fintech"):
```

**NOTE**: If the user chose a Laravel backend in Q3, the "Backend API" question is automatically answered yes with `API_URL` set to `http://{backendSlug}.test` (Laravel Herd). Do NOT ask a separate backend question.

If the user did NOT choose a Laravel backend, ask:

**Q5b: Backend API (non-Laravel only)**
```
Does your app need a backend API? [y/N]
```
If yes, ask for the API base URL (default: `http://localhost:3000`).

### Step 2: Confirm

Present a summary and ask for confirmation:

```
Here's what I'll create:

  App:          {name}
  Slug:         {slug}
  Bundle ID:    {bundleId}
  IAP:          {yes/no}
  Design vibe:  {vibe}

  Directory:    ./{slug}/
```

If Laravel backend was selected, also show:

```
  Laravel Backend:
    Name:       {backendSlug}
    Directory:  ./{backendSlug}/
    Auth:       Sanctum API tokens {yes/no}
    Monitoring: {Both/Pulse/Telescope/Neither}
    API URL:    http://{backendSlug}.test
```

```
Ready to go? [Y/n]
```

### Step 3: Scaffold Expo App

Follow the steps below in order. Run commands from the CURRENT WORKING DIRECTORY (the parent of the new project).

#### 3.1 Create Expo App

```bash
npx create-expo-app@latest {slug} --yes
```

#### 3.2 Clean Up Boilerplate

Remove the default template files that we'll replace:

```bash
cd {slug}
rm -rf app components constants hooks scripts/reset-project.js
mkdir -p src/app src/components src/hooks src/lib src/features
```

#### 3.3 Install Core Dependencies

```bash
npm install \
  tailwindcss@^4 \
  uniwind@^1 \
  heroui-native@^1 \
  tailwind-merge@^3 \
  tailwind-variants@^3 \
  clsx@^2 \
  zustand@^5 \
  @tanstack/react-query@^5 \
  @tanstack/react-form@^1 \
  zod@^4 \
  react-native-mmkv@^4 \
  @react-native-community/netinfo \
  react-native-gesture-handler \
  react-native-reanimated \
  react-native-safe-area-context \
  react-native-screens \
  @gorhom/bottom-sheet@^5 \
  expo-image \
  react-native-svg \
  expo-haptics \
  expo-linear-gradient \
  expo-secure-store \
  expo-sharing \
  expo-clipboard \
  expo-crypto \
  expo-file-system \
  expo-print \
  expo-web-browser \
  dotenv
```

If **IAP** was selected:
```bash
npm install react-native-purchases react-native-purchases-ui
```

#### 3.4 Install Dev Dependencies

```bash
npm install -D @testing-library/react-native @types/jest jest-expo
```

#### 3.5 Configure Metro

Read [references/wiring-guide.md](references/wiring-guide.md) for the exact file contents.

Write `metro.config.js` — wrap Expo's default config with `withUniwindConfig`, CSS entry at `./src/global.css`.

#### 3.6 Configure TypeScript

Replace `tsconfig.json` — extend `expo/tsconfig.base`, enable strict mode, add `@/*` and `@/assets/*` path aliases.

#### 3.7 Configure ESLint

Replace `eslint.config.js` — use `eslint-config-expo/flat`, ignore `dist/*`.

#### 3.8 Create Global CSS

Read [references/wiring-guide.md](references/wiring-guide.md) for the template.

Write `src/global.css` — import tailwindcss, uniwind, heroui-native/styles. Add `@source` for heroui-native. Add `@theme` block with design tokens derived from the user's vibe answer. Add `@layer theme` with light variant overrides.

**IMPORTANT**: Generate appropriate OKLCH color values based on the user's design vibe. Use the DESIGN.md as the source of truth for colors — generate DESIGN.md first, then derive global.css tokens from it.

#### 3.9 Create Lib Files

Read [references/wiring-guide.md](references/wiring-guide.md) for exact file contents.

Create these files:
- `src/lib/cn.ts` — clsx + tailwind-merge utility
- `src/lib/storage.ts` — MMKV wrapper with typed Storage interface
- `src/lib/query.tsx` — QueryClient with defaults (5min staleTime, retry 2) + NetInfo online manager + QueryProvider component

If **Laravel backend with Sanctum** was selected, also create:
- `src/lib/api.ts` — fetch wrapper with Bearer token from MMKV

Read [references/auth-guide.md](references/auth-guide.md) for the exact `api.ts` file contents.

#### 3.10 Create Root Layout

Write `src/app/_layout.tsx` — full provider hierarchy.

If **Laravel backend with Sanctum** was selected, use the auth-enabled layout from [references/auth-guide.md](references/auth-guide.md) which includes AuthGuard and auth state hydration.

If no backend auth, use the standard layout from [references/wiring-guide.md](references/wiring-guide.md):

```
import '../global.css'

GestureHandlerRootView
  └─ SafeAreaProvider
       └─ SafeAreaListener (Uniwind.updateInsets)
            └─ HeroUINativeProvider
                 └─ QueryProvider
                      └─ Stack (headerShown: false)
```

#### 3.11 Create Index Screen

Write `src/app/index.tsx` — a simple full-screen centered layout with a rocket emoji (Text, fontSize 64) and "Ship!" text below it. Style with Tailwind classes using the project's background color. Keep it minimal — this is just a placeholder.

#### 3.12 Create Auth Feature (if Laravel + Sanctum)

If **Laravel backend with Sanctum** was selected, read [references/auth-guide.md](references/auth-guide.md) and create:

- `src/features/auth/types.ts` — User, LoginRequest, RegisterRequest, AuthResponse types
- `src/features/auth/api.ts` — login, register, logout, getUser functions
- `src/features/auth/store.ts` — Zustand auth store with MMKV persistence
- `src/app/login.tsx` — Minimal login screen (email + password + button)

#### 3.13 Create App Config

Replace `app.json` with `app.config.ts`:

```typescript
import { config } from 'dotenv';
import { type ExpoConfig } from 'expo/config';
import path from 'path';

config({ path: path.resolve(__dirname, '.env.production') });
config({ path: path.resolve(__dirname, '.env') });

const appConfig: ExpoConfig = {
  name: '{APP_NAME}',
  slug: '{SLUG}',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/images/icon.png',
  scheme: '{SLUG}app',
  userInterfaceStyle: 'automatic',
  ios: {
    icon: './assets/images/icon.png',
    bundleIdentifier: '{BUNDLE_ID}',
    infoPlist: {
      ITSAppUsesNonExemptEncryption: false,
    },
  },
  android: {
    package: '{BUNDLE_ID}',
    adaptiveIcon: {
      backgroundColor: '#FFFFFF',
      foregroundImage: './assets/images/android-icon-foreground.png',
      backgroundImage: './assets/images/android-icon-background.png',
      monochromeImage: './assets/images/android-icon-monochrome.png',
    },
  },
  splash: {
    image: './assets/images/icon.png',
    resizeMode: 'contain',
    backgroundColor: '#FFFFFF',
  },
  web: {
    output: 'static',
    favicon: './assets/images/favicon.png',
  },
  plugins: [
    'expo-router',
    [
      'expo-splash-screen',
      {
        backgroundColor: '#FFFFFF',
        ios: { image: './assets/images/icon.png', imageWidth: 200 },
        android: { image: './assets/images/icon.png', imageWidth: 150 },
      },
    ],
    'expo-secure-store',
    'expo-sharing',
  ],
  experiments: {
    typedRoutes: true,
    reactCompiler: true,
  },
  extra: {
    router: {},
    eas: {
      projectId: 'YOUR_EAS_PROJECT_ID',
    },
  },
};

export default { expo: appConfig };
```

Delete the old `app.json`.

#### 3.14 Create Environment Config

Write `env.ts`:

```typescript
import Constants from 'expo-constants';

const extra = Constants.expoConfig?.extra ?? {};

export const Env = {
  APP_ENV: (process.env.EXPO_PUBLIC_APP_ENV ?? 'development') as
    | 'development'
    | 'staging'
    | 'production',
  API_URL: process.env.EXPO_PUBLIC_API_URL ?? '{API_URL}',
  // Add REVENUECAT_API_KEY if IAP was selected:
  // REVENUECAT_API_KEY: process.env.EXPO_PUBLIC_REVENUECAT_API_KEY ?? '',
  ...extra,
} as const;
```

- If Laravel backend was selected, set `{API_URL}` to `http://{backendSlug}.test`
- If non-Laravel backend was selected, use the user's provided URL
- If no backend, use `http://localhost:3000` as placeholder

Write `.env.example` with the corresponding `EXPO_PUBLIC_*` variables.

#### 3.15 Create EAS Config

Write `eas.json`:

```json
{
  "cli": {
    "version": ">= 18.4.0",
    "appVersionSource": "remote"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": { "APP_ENV": "development" }
    },
    "preview": {
      "distribution": "internal",
      "env": { "APP_ENV": "production" }
    },
    "production": {
      "autoIncrement": true,
      "env": { "APP_ENV": "production" }
    }
  },
  "submit": {
    "production": {}
  }
}
```

#### 3.16 Create .gitignore, .easignore, and .claude/settings.local.json

Read [references/wiring-guide.md](references/wiring-guide.md) for the complete file contents.

- `.gitignore` — covers node_modules, .expo, dist, native dirs, build artifacts, env files, etc.
- `.easignore` — additionally excludes .git, docs, design assets, editor configs.
- `.claude/settings.local.json` — AI agent permissions for common Expo development commands (git, npm, expo, jest, eslint, tsc, gh, etc.)

Create the `.claude/` directory first: `mkdir -p .claude`

#### 3.17 Update package.json Scripts

Read the existing package.json, then update the `scripts` section:

```json
{
  "start": "expo start",
  "clean": "npx expo prebuild --clean",
  "android": "expo run:android",
  "ios": "expo run:ios",
  "ios:device": "expo run:ios --device",
  "web": "expo start --web",
  "build:dev": "eas build --profile development --platform ios",
  "build:preview": "eas build --profile preview --platform ios",
  "build:production": "eas build --profile production --platform ios",
  "build:production:local": "bash scripts/sync-production-env.sh && set -a && . .env.production && set +a && eas build --profile production --platform ios --local",
  "submit:ios": "eas submit --profile production --platform ios --path $(ls -t *.ipa | head -1)",
  "lint": "expo lint",
  "type-check": "tsc --noEmit",
  "test": "jest",
  "check-all": "npm run lint && npm run type-check && npm run test"
}
```

Also update/add the `jest` config in package.json:

```json
{
  "jest": {
    "preset": "jest-expo",
    "moduleNameMapper": {
      "^@/(.*)$": "<rootDir>/src/$1"
    },
    "transformIgnorePatterns": [
      "node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|native-base|react-native-svg)"
    ]
  }
}
```

Set `"main": "expo-router/entry"`.

#### 3.18 Create Utility Scripts

Copy the script templates from this skill into the new project:

Read [scripts/sync-production-env.sh](scripts/sync-production-env.sh) and write it to `{project}/scripts/sync-production-env.sh`.

Read [scripts/optimize-images.sh](scripts/optimize-images.sh) and write it to `{project}/scripts/optimize-images.sh`.

Make both executable: `chmod +x scripts/*.sh`

#### 3.19 Generate DESIGN.md

Read [references/DESIGN-TEMPLATE.md](references/DESIGN-TEMPLATE.md) for the template structure.

Generate a DESIGN.md based on the user's vibe answer. This should include:
- Color palette with OKLCH values (primary, accent, background, surface, foreground)
- Typography recommendations
- Spacing & border radius tokens
- Brand voice guidelines
- Dark/light mode strategy

The OKLCH values from DESIGN.md should match what you put in `src/global.css`.

#### 3.20 Generate CLAUDE.md

Read [references/CLAUDE-TEMPLATE.md](references/CLAUDE-TEMPLATE.md) for the template.

Generate a comprehensive CLAUDE.md tailored to the project. Fill in:
- Actual app name, slug, and technology stack
- The real project structure
- All npm scripts
- Key patterns (features, routes, forms, data fetching, state, styling, storage)
- Essential rules
- Backend API section (if backend was selected — see the template for Laravel-specific content)
- Reference to DESIGN.md for design tokens

#### 3.21 Generate README.md

Generate a README.md with:
- App name and brief description
- Getting started (install, start, run on device)
- Project structure overview
- Version numbers and releasing guide (semver, EAS build profiles)
- Local build instructions

#### 3.22 Install Project-Level Agent Skills

```bash
cd {project_root}
npx skills add vercel-labs/agent-skills@react-native-guidelines -y
npx skills add heroui/heroui-native-skill@heroui-native -y
npx skills add nicepkg/uniwind-skill@uniwind -y
npx skills add vercel-labs/agent-skills@react-best-practices -y
```

If **IAP** was selected:
```bash
npx skills add openclaw/revenuecat-skill@revenuecat -y
```

**NOTE**: If any `npx skills add` command fails (skill not found, network error, etc.), skip it gracefully and inform the user. The project will still work without these skills — they just provide extra agent context. Use `npx skills find <keyword>` to search for the correct skill identifier if the above names are outdated.

Also install `find-skills` globally if not already present:
```bash
npx skills add vercel-labs/skills@find-skills -g -y 2>/dev/null || true
```

#### 3.23 Initialize Git

```bash
git add -A
git commit -m "Initial scaffold via create-expo-app skill"
```

### Step 4: Scaffold Laravel Backend (if selected)

**IMPORTANT**: Only execute this step if the user chose a Laravel backend in Q3. Run commands from the ORIGINAL WORKING DIRECTORY (the parent of both projects, same level as the Expo app).

Read [references/laravel-guide.md](references/laravel-guide.md) for exact code and file contents referenced below.

#### 4.1 Create Laravel App

Ensure the `laravel` CLI is available. If not:
```bash
composer global require laravel/installer
```

Create the app with the React starter kit:
```bash
laravel new {backendSlug} --using=react
```

Install the API scaffolding (Sanctum):
```bash
cd {backendSlug}
php artisan install:api
```

#### 4.2 Install Monitoring Tools

Based on the user's Q3c answer, install Pulse and/or Telescope. See [references/laravel-guide.md](references/laravel-guide.md) section 2 for exact commands.

Run `php artisan migrate` after publishing configs.

Then:
- Add access gates so only `test@example.com` can view Pulse/Telescope (section 2a)
- Disable Pulse/Telescope in `phpunit.xml` (section 2b)

#### 4.3 Wire Sidebar Navigation

Add Pulse and/or Telescope links to the admin sidebar. See [references/laravel-guide.md](references/laravel-guide.md) section 3 for:

1. Create `resources/js/components/nav-footer.tsx` — the NavFooter component
2. Update `resources/js/components/app-sidebar.tsx` — add imports, footer nav items, and NavFooter in SidebarFooter before NavUser

Only include items for the tools the user selected. The links open in new tabs (`target="_blank"`).

#### 4.4 Create API Auth Endpoints (if Sanctum selected)

See [references/laravel-guide.md](references/laravel-guide.md) section 4 for exact code:

1. Create `app/Http/Controllers/Api/V1/AuthController.php` — login, register, logout, user endpoints
2. Add routes to `routes/api.php` under `/v1/auth/` prefix

Endpoints:
- `POST /api/v1/auth/login` — returns token + user
- `POST /api/v1/auth/register` — returns token + user
- `POST /api/v1/auth/logout` — revokes token (auth required)
- `GET /api/v1/auth/user` — returns current user (auth required)

#### 4.5 Seed Test User

Update `database/seeders/DatabaseSeeder.php` with a test user:
- Email: `test@example.com`
- Password: `bcrypt('password')`
- Name: `Test User`

See [references/laravel-guide.md](references/laravel-guide.md) section 5 for exact code.

Run:
```bash
php artisan migrate:fresh --seed
```

#### 4.6 Production Safety

Add `DB::prohibitDestructiveCommands` and `CarbonImmutable` to `AppServiceProvider`. See [references/laravel-guide.md](references/laravel-guide.md) section 6.

#### 4.7 Install Laravel Boost

```bash
composer require --dev laravel/boost
```

#### 4.8 Create Custom Boost Guidelines

Create the `.ai/guidelines/` directory and add `companion-app.md` with cross-project references. See [references/laravel-guide.md](references/laravel-guide.md) section 8 for the exact template.

This file tells the AI:
- Where the companion Expo app lives (`../{slug}/`)
- How to handle cross-project commands ("check the app", "create an issue in the app")
- Where the API contract is documented (`docs/api-specs.md`)
- The app's tech stack

#### 4.9 Run Boost Install

```bash
php artisan boost:install
```

This generates AGENTS.md and CLAUDE.md (including the custom companion-app guideline), installs skills, and configures MCP servers automatically.

#### 4.10 Generate API Specs

Generate `docs/api-specs.md` by introspecting the actual Laravel routes and controllers. See [references/laravel-guide.md](references/laravel-guide.md) section 10 for the structure.

**IMPORTANT**: Do not use a static template. Read the actual routes (`php artisan route:list --json`) and controller code, then generate accurate documentation from the real implementation. Document every `/api/*` route with HTTP method, URL, auth requirements, request/response format, and validation rules.

#### 4.11 Commit

```bash
git add -A
git commit -m "Initial scaffold with React starter kit, Sanctum API, and Laravel Boost"
```

### Step 5: Done!

Print a summary:

```
Your app is ready!

  cd {slug}
  npm start

Next steps:
  1. Run `npx eas init` to connect to EAS (for builds)
  2. Update the EAS project ID in app.config.ts
  3. Replace the app icon in assets/images/
  4. Review DESIGN.md for your design tokens
  5. Review CLAUDE.md for project conventions
  {6. Set up RevenueCat API key in .env (if IAP)}
```

If Laravel backend was selected, also print:

```
Laravel backend ready!

  cd {backendSlug}
  php artisan serve   # or use Laravel Herd at http://{backendSlug}.test

  Test login:
    Email:    test@example.com
    Password: password

  The API contract is documented in {backendSlug}/docs/api-specs.md.
  Both projects know about each other — just say "check the backend" or "check the app".
```
