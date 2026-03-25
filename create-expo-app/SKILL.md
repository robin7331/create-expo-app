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
  version: "3.0.0"
---

# Create Expo App

Scaffold a production-ready React Native Expo app — optionally paired with a Laravel backend — in minutes.

## Architecture

This skill separates concerns into three layers:

1. **Chat context** — gather parameters from the user (questions, confirmation)
2. **Shell scripts** — deterministic scaffolding (clone boilerplate, CLI commands, template copying)
3. **Agents** — intelligent generation (DESIGN.md from vibe, CLAUDE.md, README.md, global.css colors)

## Step 1: Ask Questions

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
Describe your app's visual vibe in a few words (e.g., "playful kids app", "minimal fitness tracker", "dark premium fintech"):
```

**NOTE**: If the user chose a Laravel backend in Q3, the "Backend API" question is automatically answered yes with `API_URL` set to `http://{backendSlug}.test` (Laravel Herd). Do NOT ask a separate backend question.

If the user did NOT choose a Laravel backend, ask:

**Q5b: Backend API (non-Laravel only)**
```
Does your app need a backend API? [y/N]
```
If yes, ask for the API base URL (default: `http://localhost:3000`).

## Step 2: Confirm

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

## Step 3: Scaffold Expo App

### 3.1 Run scaffold script

Determine the `API_URL`:
- If Laravel backend: `http://{backendSlug}.test`
- If non-Laravel backend: user's provided URL
- If no backend: `http://localhost:3000`

Run from the CURRENT WORKING DIRECTORY:

```bash
bash {SKILL_DIR}/scripts/scaffold-expo.sh "{slug}" "{APP_NAME}" "{bundleId}" "{API_URL}"
```

Where `{SKILL_DIR}` is the absolute path to this skill's directory (the folder containing this SKILL.md).

### 3.2 Auto-invoke /add-auth (if Sanctum selected)

If the user selected a Laravel backend with Sanctum API tokens (Q3b = yes), run the add-auth script in the newly scaffolded project:

```bash
cd {slug}
bash scripts/add-auth.sh
```

### 3.3 Auto-invoke /add-iap (if IAP selected)

If the user selected in-app purchases (Q4 = yes), run the add-iap script in the newly scaffolded project:

```bash
cd {slug}
bash scripts/add-iap.sh
```

### 3.4 Generate DESIGN.md (Agent)

Generate a DESIGN.md in the project directory based on the user's design vibe answer.

Read [references/DESIGN-TEMPLATE.md](references/DESIGN-TEMPLATE.md) for the template structure.

The DESIGN.md should include:
- Color palette with OKLCH values (primary, accent, background, surface, foreground)
- Typography recommendations
- Spacing & border radius tokens
- Brand voice guidelines
- Dark/light mode strategy

### 3.5 Update global.css colors (Agent)

After generating DESIGN.md, update `src/global.css` in the project to replace the default color values with the OKLCH values from DESIGN.md. The `@theme` and `@layer theme` blocks must match DESIGN.md exactly.

### 3.6 Generate CLAUDE.md (Agent)

Read [references/CLAUDE-TEMPLATE.md](references/CLAUDE-TEMPLATE.md) for the template.

Generate a CLAUDE.md tailored to the project. Fill in:
- Actual app name, slug, and technology stack
- The real project structure
- All npm scripts
- Key patterns (features, routes, forms, data fetching, state, styling, storage)
- Essential rules
- Backend API section (if backend was selected — see the template for Laravel-specific and generic variants)
- Reference to DESIGN.md for design tokens

### 3.7 Generate README.md (Agent)

Generate a README.md with:
- App name and brief description
- Getting started (install, start, run on device)
- Project structure overview
- Version numbers and releasing guide (semver, EAS build profiles)
- Local build instructions

### 3.8 Final commit

```bash
cd {slug}
git add -A
git commit -m "Add DESIGN.md, CLAUDE.md, README.md, and design tokens"
```

## Step 4: Scaffold Laravel Backend (if selected)

**IMPORTANT**: Only execute this step if the user chose a Laravel backend in Q3. Run commands from the ORIGINAL WORKING DIRECTORY (the parent of both projects).

### 4.1 Run scaffold script

Build the flags based on the user's answers:

```bash
bash {SKILL_DIR}/scripts/scaffold-laravel.sh "{backendSlug}" [--sanctum] [--pulse] [--telescope]
```

Include `--sanctum` if Q3b = yes. Include `--pulse` and/or `--telescope` based on Q3c.

### 4.2 Code modifications (Agent)

After the scaffold script completes, the following code modifications require reading and modifying files generated by `laravel new`. Run these from inside the `{backendSlug}/` directory.

Read [references/laravel-guide.md](references/laravel-guide.md) for exact code and file contents.

**If Sanctum was selected (Q3b = yes):**

1. Create `app/Http/Controllers/Api/V1/AuthController.php` — login, register, logout, user endpoints (see laravel-guide.md section 4)
2. Add routes to `routes/api.php` under `/v1/auth/` prefix (see laravel-guide.md section 4)
3. Update `database/seeders/DatabaseSeeder.php` with test user: `test@example.com` / `password` (see laravel-guide.md section 5)
4. Run: `php artisan migrate:fresh --seed`

**If Pulse and/or Telescope was selected (Q3c):**

5. Add access gates so only `test@example.com` can view Pulse/Telescope (see laravel-guide.md section 2a)
6. Disable Pulse/Telescope in `phpunit.xml` (see laravel-guide.md section 2b)
7. Wire sidebar navigation — create `resources/js/components/nav-footer.tsx` and update `resources/js/components/app-sidebar.tsx` (see laravel-guide.md section 3)

**Always:**

8. Add `DB::prohibitDestructiveCommands` and `CarbonImmutable` to `AppServiceProvider` (see laravel-guide.md section 6)
9. Create `.ai/guidelines/companion-app.md` with cross-project references (see laravel-guide.md section 8) — replace `{slug}` with the Expo app slug
10. Run: `php artisan boost:install`
11. Generate `docs/api-specs.md` by introspecting actual routes (`php artisan route:list --json`) and controller code — do NOT use a static template (see laravel-guide.md section 10)

### 4.3 Commit

```bash
cd {backendSlug}
git add -A
git commit -m "Initial scaffold with React starter kit, Sanctum API, and Laravel Boost"
```

## Step 5: Done!

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
