---
name: create-expo-app
description: >
  Scaffold a production-ready React Native Expo app with Tailwind CSS v4 (Uniwind),
  HeroUI Native, Zustand, React Query, MMKV, and full EAS build config.
  Use when the user wants to create a new Expo app, start a new React Native project,
  or scaffold a mobile app. Triggers on: "create expo app", "new react native project",
  "scaffold mobile app", "start a new app", "bootstrap expo project".
license: MIT
compatibility: Requires Node.js 18+, npm, and npx. macOS recommended for iOS builds.
metadata:
  author: robin7331
  version: "1.0.0"
---

# Create Expo App

Scaffold a production-ready React Native Expo app with a modern stack in minutes.

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

**Q3: In-App Purchases**
```
Will your app have in-app purchases or subscriptions? [y/N]
```

**Q4: Push Notifications**
```
Do you need push notifications? [y/N]
```

**Q5: Backend**
```
Does your app need a backend API? [y/N]
```
If yes, ask for the API base URL (default: `http://localhost:3000`).

**Q6: Design Vibe**
```
Describe your app's visual vibe in a few words (e.g., "playful kids app", "minimal fitness tracker", "dark premium fintech"):
```

### Step 2: Confirm

Present a summary and ask for confirmation:

```
Here's what I'll create:

  App:          {name}
  Slug:         {slug}
  Bundle ID:    {bundleId}
  IAP:          {yes/no}
  Push:         {yes/no}
  Backend:      {yes/no} {apiUrl if yes}
  Design vibe:  {vibe}

  Directory:    ./{slug}/

Ready to go? [Y/n]
```

### Step 3: Scaffold

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

If **push notifications** was selected:
```bash
npm install expo-notifications expo-device expo-constants
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

#### 3.10 Create Root Layout

Write `src/app/_layout.tsx` — full provider hierarchy:

```
import '../global.css'

GestureHandlerRootView
  └─ SafeAreaProvider
       └─ SafeAreaListener (Uniwind.updateInsets)
            └─ HeroUINativeProvider
                 └─ QueryProvider
                      └─ Stack (headerShown: false)
```

See [references/wiring-guide.md](references/wiring-guide.md) for exact code.

#### 3.11 Create Index Screen

Write `src/app/index.tsx` — a simple full-screen centered layout with a rocket emoji (Text, fontSize 64) and "Ship!" text below it. Style with Tailwind classes using the project's background color. Keep it minimal — this is just a placeholder.

#### 3.12 Create App Config

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
    // Add 'expo-notifications' here if push was selected
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

#### 3.13 Create Environment Config

Write `env.ts`:

```typescript
import Constants from 'expo-constants';

const extra = Constants.expoConfig?.extra ?? {};

export const Env = {
  APP_ENV: (process.env.EXPO_PUBLIC_APP_ENV ?? 'development') as
    | 'development'
    | 'staging'
    | 'production',
  API_URL: process.env.EXPO_PUBLIC_API_URL ?? '{API_URL_OR_DEFAULT}',
  // Add REVENUECAT_API_KEY if IAP was selected:
  // REVENUECAT_API_KEY: process.env.EXPO_PUBLIC_REVENUECAT_API_KEY ?? '',
  ...extra,
} as const;
```

Write `.env.example` with the corresponding `EXPO_PUBLIC_*` variables.

#### 3.14 Create EAS Config

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

#### 3.15 Create .gitignore and .easignore

Read [references/wiring-guide.md](references/wiring-guide.md) for the complete file contents. The .gitignore should cover node_modules, .expo, dist, native dirs, build artifacts, env files, etc. The .easignore should additionally exclude .git, docs, design assets, editor configs.

#### 3.16 Update package.json Scripts

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

#### 3.17 Create Utility Scripts

Copy the script templates from this skill into the new project:

Read [scripts/sync-production-env.sh](scripts/sync-production-env.sh) and write it to `{project}/scripts/sync-production-env.sh`.

Read [scripts/optimize-images.sh](scripts/optimize-images.sh) and write it to `{project}/scripts/optimize-images.sh`.

Make both executable: `chmod +x scripts/*.sh`

#### 3.18 Generate DESIGN.md

Read [references/DESIGN-TEMPLATE.md](references/DESIGN-TEMPLATE.md) for the template structure.

Generate a DESIGN.md based on the user's vibe answer. This should include:
- Color palette with OKLCH values (primary, accent, background, surface, foreground)
- Typography recommendations
- Spacing & border radius tokens
- Brand voice guidelines
- Dark/light mode strategy

The OKLCH values from DESIGN.md should match what you put in `src/global.css`.

#### 3.19 Generate CLAUDE.md

Read [references/CLAUDE-TEMPLATE.md](references/CLAUDE-TEMPLATE.md) for the template.

Generate a comprehensive CLAUDE.md tailored to the project. Fill in:
- Actual app name, slug, and technology stack
- The real project structure
- All npm scripts
- Key patterns (features, routes, forms, data fetching, state, styling, storage)
- Essential rules
- Backend API section (if backend was selected)
- Reference to DESIGN.md for design tokens

#### 3.20 Generate README.md

Generate a README.md with:
- App name and brief description
- Getting started (install, start, run on device)
- Project structure overview
- Version numbers and releasing guide (semver, EAS build profiles)
- Local build instructions

#### 3.21 Install Project-Level Agent Skills

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

#### 3.22 Initialize Git

```bash
git add -A
git commit -m "Initial scaffold via create-expo-app skill"
```

### Step 4: Done!

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
  {6. Configure push notification permissions (if push)}
```
