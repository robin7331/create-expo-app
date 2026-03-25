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
  version: "4.0.0"
---

# Create Expo App

Scaffold a production-ready React Native Expo app — optionally paired with a Laravel backend — in minutes.

## Architecture

This skill separates concerns into three layers:

1. **Chat context** — gather parameters from the user (questions, confirmation)
2. **Shell scripts** — deterministic scaffolding (clone boilerplate, CLI commands, template copying)
3. **Agents** — intelligent generation (DESIGN.md from vibe, CLAUDE.md, README.md, global.css colors)

### Phased Execution

The skill runs in **phases** to keep token usage manageable. After each phase, progress is saved to `.create-expo-app-state.json` in the working directory. The user can clear context (via `/compact` or starting a new conversation) and re-invoke `/create-expo-app` to resume from where they left off.

| Phase | What happens | Token cost |
|-------|-------------|------------|
| 1 | Ask questions, confirm, run all scaffold shell scripts | Low |
| 2 | Generate DESIGN.md, global.css, CLAUDE.md, README.md — commit Expo app | High (agent work) |
| 3 | Generate Laravel API docs — commit backend — print summary | Medium (only if Laravel selected) |

If no Laravel backend was selected, Phase 2 is the final phase.

## On Invoke: Check for State File

When the skill is invoked, **FIRST** check if `.create-expo-app-state.json` exists in the current working directory.

- **If it exists**: Read it, determine the next incomplete phase, and tell the user:
  ```
  Resuming from Phase {N}...
  ```
  Then jump directly to that phase — do NOT re-ask questions.
- **If it does not exist**: Start from Phase 1.

### State File Format

```json
{
  "version": 1,
  "currentPhase": 2,
  "completedPhases": [1],
  "params": {
    "name": "My App",
    "slug": "my-app",
    "bundleId": "com.example.my.app",
    "laravel": true,
    "backendSlug": "my-app-backend",
    "sanctum": true,
    "monitoring": "both",
    "iap": false,
    "vibe": "Black / white shadcn neutral",
    "apiUrl": "http://my-app-backend.test",
    "hasBackendApi": true
  }
}
```

---

## Phase 1: Gather & Scaffold

### 1.1 Ask Questions

**IMPORTANT**: Ask these questions ONE AT A TIME. Wait for each answer before proceeding.

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
Pick a visual vibe for your app:

  1. Black / white shadcn neutral
  2. Dark premium fintech
  3. Soft pastel wellness
  4. Bold neon cyberpunk
  5. Warm earthy organic
  6. Clean corporate SaaS
  7. Playful & colorful
  8. Minimal mono
  9. Luxury dark
  10. Custom (describe your own)

Enter a number [1]:
```
If the user picks 10, ask them to describe their vibe in a few words. Default is 1 if they press enter.

**NOTE**: If the user chose a Laravel backend in Q3, the "Backend API" question is automatically answered yes with `API_URL` set to `http://{backendSlug}.test` (Laravel Herd). Do NOT ask a separate backend question.

If the user did NOT choose a Laravel backend, ask:

**Q5b: Backend API (non-Laravel only)**
```
Does your app need a backend API? [y/N]
```
If yes, ask for the API base URL (default: `http://localhost:3000`).

### 1.2 Confirm

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

### 1.3 Scaffold Expo App

Determine the `API_URL`:
- If Laravel backend: `http://{backendSlug}.test`
- If non-Laravel backend: user's provided URL
- If no backend: `http://localhost:3000`

Run from the CURRENT WORKING DIRECTORY:

```bash
bash {SKILL_DIR}/scripts/scaffold-expo.sh "{slug}" "{APP_NAME}" "{bundleId}" "{API_URL}"
```

Where `{SKILL_DIR}` is the absolute path to this skill's directory (the folder containing this SKILL.md).

**If Sanctum selected (Q3b = yes)**, run in the newly scaffolded project:

```bash
cd {slug}
bash scripts/add-auth.sh
```

**If IAP selected (Q4 = yes)**, run in the newly scaffolded project:

```bash
cd {slug}
bash scripts/add-iap.sh
```

### 1.4 Scaffold Laravel Backend (if selected)

**IMPORTANT**: Only execute if the user chose a Laravel backend in Q3. Run from the ORIGINAL WORKING DIRECTORY (the parent of both projects).

```bash
bash {SKILL_DIR}/scripts/scaffold-laravel.sh "{backendSlug}" "{slug}"
```

This clones the boilerplate, replaces the companion app slug placeholder, sets up `.env` with the correct `APP_NAME` and `APP_URL`, installs dependencies, runs migrations, and initializes git.

**If Sanctum selected (Q3b = yes)**:

```bash
cd {backendSlug}
bash scripts/add-sanctum-api.sh
```

**If monitoring tools selected (Q3c)**:

```bash
cd {backendSlug}
bash scripts/add-pulse-telescope.sh [--pulse] [--telescope]
```

Include the flags based on the user's Q3c answer.

### 1.5 Save State & Suggest Context Clear

Write `.create-expo-app-state.json` to the working directory with all parameters and `completedPhases: [1]`, `currentPhase: 2`.

Then print:

```
Phase 1 complete — projects scaffolded!

Next up: Phase 2 will generate DESIGN.md, CLAUDE.md, README.md, and apply your design tokens.

To free up context before continuing (recommended):
  - Type /compact to compress this conversation, or
  - Start a new conversation and run /create-expo-app — it will resume automatically.

Or just say "continue" to keep going now.
```

**Wait for the user to respond before proceeding to Phase 2.**

---

## Phase 2: Generate Expo Project Docs

Read parameters from the state file (or from conversation context if continuing without a clear).

### 2.1 Update DESIGN.md (Agent)

The boilerplate ships with a `DESIGN.md` containing neutral defaults. Read it, then update the values based on the user's design vibe answer:

- Replace the OKLCH color values (primary, accent, background, surface, foreground) with colors that match the vibe
- Update the brand voice section to reflect the app's personality
- Update the dark/light mode strategy if appropriate
- Keep the same document structure — only change the values

### 2.2 Update global.css colors (Agent)

After generating DESIGN.md, update `src/global.css` in the project to replace the default color values with the OKLCH values from DESIGN.md. The `@theme` and `@layer theme` blocks must match DESIGN.md exactly.

### 2.3 Update CLAUDE.md (Agent)

The boilerplate already ships with a complete CLAUDE.md covering the stack, patterns, and conventions. Read the existing `CLAUDE.md` in the project, then **append** sections based on the user's choices. Do NOT regenerate the whole file.

**If Laravel backend was selected**, append a "Backend API (Laravel)" section with:
- Backend location: `../{backendSlug}/`
- Cross-project workflows ("check the backend" → navigate to `../{backendSlug}/`)
- API contract location: `../{backendSlug}/docs/api-specs.md`
- API base URL: `http://{backendSlug}.test`
- Auth details (if Sanctum: token stored in MMKV, attached via `src/lib/api.ts`, auth logic in `src/features/auth/`)
- Convention: snake_case on the wire, map to camelCase at API boundary

**If non-Laravel backend was selected**, append a "Backend API" section with:
- API base URL from user's answer
- Convention: all API responses return JSON, snake_case → camelCase at boundary

**If IAP was selected**, append RevenueCat to the technology stack list.

**Always**, update the project structure in CLAUDE.md if auth added `lib/api.ts` or `features/auth/`.

### 2.4 Generate README.md (Agent)

Generate a README.md with:
- App name and brief description
- Getting started (install, start, run on device)
- Project structure overview
- Version numbers and releasing guide (semver, EAS build profiles)
- Local build instructions

### 2.5 Commit Expo App

```bash
cd {slug}
git add -A
git commit -m "Add DESIGN.md, CLAUDE.md, README.md, and design tokens"
```

### 2.6 Save State & Finish or Continue

Update the state file: add `2` to `completedPhases`, set `currentPhase: 3`.

**If NO Laravel backend was selected**: this is the final phase. Delete `.create-expo-app-state.json` and jump to the **Done** section below.

**If Laravel backend was selected**, print:

```
Phase 2 complete — Expo app docs generated and committed!

Next up: Phase 3 will generate Laravel API docs and finalize the backend.

To free up context before continuing (recommended):
  - Type /compact to compress this conversation, or
  - Start a new conversation and run /create-expo-app — it will resume automatically.

Or just say "continue" to keep going now.
```

**Wait for the user to respond before proceeding to Phase 3.**

---

## Phase 3: Generate Laravel Docs & Finish

**Only runs if a Laravel backend was selected.** Read parameters from the state file (or from conversation context if continuing without a clear).

### 3.1 Generate API Docs (Agent)

1. Run `php artisan route:list --json` in the `{backendSlug}` directory to get all registered routes
2. Read the AuthController code at `app/Http/Controllers/Api/V1/AuthController.php`
3. Generate `docs/api-specs.md` documenting every `/api/*` route with:
   - HTTP method and URL
   - Authentication requirements
   - Request body / query parameters (with types and validation rules from the controller)
   - Response format (with example JSON)
   - Error responses

Do NOT use a static template — generate from the actual code.

### 3.2 Commit Laravel Backend

```bash
cd {backendSlug}
git add -A
git commit -m "Add Sanctum API auth, monitoring tools, and API docs"
```

### 3.3 Clean Up & Done

Delete `.create-expo-app-state.json`, then jump to the **Done** section below.

---

## Done

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
```

If IAP was selected, add:
```
  6. Set up RevenueCat API key in .env
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
