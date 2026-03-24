# Laravel Backend Guide

Exact instructions and code for scaffolding the Laravel backend. Referenced by SKILL.md.

## 1. Create Laravel App

Ensure the `laravel` CLI is available. If not, install it first:

```bash
composer global require laravel/installer
```

Then create the app with the React starter kit:

```bash
laravel new {BACKEND_SLUG} --using=react
```

This installs Laravel with Inertia + React + Tailwind + Fortify auth out of the box.

Then install the API scaffolding (Sanctum):

```bash
cd {BACKEND_SLUG}
php artisan install:api
```

## 2. Install Pulse & Telescope

Based on the user's choice, install one or both:

**Both (default):**
```bash
composer require laravel/pulse laravel/telescope
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
php artisan vendor:publish --provider="Laravel\Telescope\TelescopeServiceProvider"
php artisan migrate
```

**Pulse only:**
```bash
composer require laravel/pulse
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
php artisan migrate
```

**Telescope only:**
```bash
composer require laravel/telescope
php artisan vendor:publish --provider="Laravel\Telescope\TelescopeServiceProvider"
php artisan migrate
```

### 2a. Gate Access to Pulse & Telescope

Add access gates in `app/Providers/AppServiceProvider.php` so only the seeded test user can access these tools. Add to the `boot()` method:

```php
use Illuminate\Support\Facades\Gate;

// Inside boot():
Gate::define('viewPulse', function ($user) {
    return $user->email === 'test@example.com';
});
```

If Telescope was installed, also open `app/Providers/TelescopeServiceProvider.php` and update the `gate()` method:

```php
protected function gate(): void
{
    Gate::define('viewTelescope', function ($user) {
        return $user->email === 'test@example.com';
    });
}
```

**NOTE**: The user should replace `test@example.com` with their own email(s) before going to production. Add a comment reminding them.

### 2b. Disable Pulse & Telescope in Tests

Open `phpunit.xml` and add these env vars inside the `<php>` section:

```xml
<env name="PULSE_ENABLED" value="false"/>
<env name="TELESCOPE_ENABLED" value="false"/>
```

This prevents monitoring tools from interfering with test execution.

## 3. Wire Sidebar Navigation

### 3a. Create NavFooter Component

Create `resources/js/components/nav-footer.tsx`:

```tsx
import {
    SidebarGroup,
    SidebarGroupContent,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar';
import { type LucideIcon } from 'lucide-react';

export function NavFooter({
    items,
    ...props
}: {
    items: {
        title: string;
        href: string;
        icon: LucideIcon;
    }[];
} & React.ComponentPropsWithoutRef<typeof SidebarGroup>) {
    return (
        <SidebarGroup {...props} className="group-data-[collapsible=icon]:p-0">
            <SidebarGroupContent>
                <SidebarMenu>
                    {items.map((item) => (
                        <SidebarMenuItem key={item.title}>
                            <SidebarMenuButton asChild>
                                <a
                                    href={item.href}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="text-neutral-600 hover:text-neutral-800 dark:text-neutral-300 dark:hover:text-neutral-100"
                                >
                                    <item.icon className="h-5 w-5" />
                                    <span>{item.title}</span>
                                </a>
                            </SidebarMenuButton>
                        </SidebarMenuItem>
                    ))}
                </SidebarMenu>
            </SidebarGroupContent>
        </SidebarGroup>
    );
}
```

### 3b. Update app-sidebar.tsx

In `resources/js/components/app-sidebar.tsx`:

1. Add imports at the top:
```tsx
import { Activity, Telescope } from 'lucide-react';
import { NavFooter } from '@/components/nav-footer';
```

2. Define footer nav items (include only the ones the user selected):

```tsx
// Add this alongside the existing mainNavItems definition
const footerNavItems = [
    // Include if Pulse was selected:
    {
        title: 'Pulse',
        href: '/pulse',
        icon: Activity,
    },
    // Include if Telescope was selected:
    {
        title: 'Telescope',
        href: '/telescope',
        icon: Telescope,
    },
];
```

3. Add `NavFooter` to the `<SidebarFooter>`, **before** `<NavUser />`:

```tsx
<SidebarFooter>
    <NavFooter items={footerNavItems} className="mt-auto" />
    <NavUser />
</SidebarFooter>
```

## 4. Sanctum API Auth Endpoints

If the user chose Sanctum for mobile auth, create the API auth controller and routes.

### 4a. Create Auth Controller

Create `app/Http/Controllers/Api/V1/AuthController.php`:

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ]);
    }

    public function register(Request $request): JsonResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
        ], 201);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out']);
    }

    public function user(Request $request): JsonResponse
    {
        return response()->json($request->user());
    }
}
```

### 4b. Add API Routes

Add to `routes/api.php`:

```php
use App\Http\Controllers\Api\V1\AuthController;

Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AuthController::class, 'register']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/auth/user', [AuthController::class, 'user']);
    });
});
```

## 5. Database Seeder

Update `database/seeders/DatabaseSeeder.php` to include a test user. Find the `run()` method and ensure it contains:

```php
public function run(): void
{
    \App\Models\User::factory()->create([
        'name' => 'Test User',
        'email' => 'test@example.com',
        'password' => bcrypt('password'),
    ]);
}
```

Then run:

```bash
php artisan migrate:fresh --seed
```

## 6. Production Safety

Add these to `app/Providers/AppServiceProvider.php` in the `boot()` method:

```php
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\Facades\DB;

// Inside boot():
DB::prohibitDestructiveCommands($this->app->isProduction());
Date::use(CarbonImmutable::class);
```

- `prohibitDestructiveCommands` prevents accidental `migrate:fresh`, `db:wipe`, etc. in production
- `CarbonImmutable` prevents subtle date mutation bugs

## 7. Install Laravel Boost

```bash
composer require --dev laravel/boost
```

## 8. Create Custom Boost Guidelines

Create `.ai/guidelines/companion-app.md` in the Laravel project root:

```markdown
# Companion Mobile App

This Laravel backend serves a React Native (Expo) mobile app.

## Location

The companion app project is located at `../{APP_SLUG}/`.

## Cross-Project Workflows

- When asked to "check the app", "look at the app code", or "see how the app does X", navigate to `../{APP_SLUG}/`.
- When asked to "create a GitHub issue in the app" or "create an issue for the app", run `gh issue create` from within the `../{APP_SLUG}/` directory.
- When asked about "the frontend" or "the mobile app", this refers to the Expo project at `../{APP_SLUG}/`.

## API Contract

The file `docs/api-specs.md` in this repository is the **single source of truth** for the API contract between this backend and the mobile app.

When adding or modifying API endpoints:
1. Implement the endpoint in Laravel
2. Update `docs/api-specs.md` with the endpoint documentation
3. The mobile app will reference this file to implement corresponding API calls

When asked about "api specs" or "the API contract", this refers to `docs/api-specs.md`.

## App Tech Stack

- React Native with Expo SDK
- TypeScript with strict mode
- Expo Router (file-based routing)
- TailwindCSS v4 via Uniwind
- React Query for server state / data fetching
- Zustand for global state
- MMKV for encrypted local storage
- Sanctum API tokens for authentication (Bearer token in Authorization header)
```

Replace `{APP_SLUG}` with the actual Expo app slug.

## 9. Run Boost Install

```bash
php artisan boost:install
```

This auto-detects all installed packages, generates AGENTS.md and CLAUDE.md (including the custom companion-app guideline), installs skills, and configures MCP servers.

## 10. Generate docs/api-specs.md

After all endpoints are in place, generate the API specification:

1. Run `php artisan route:list --json` to get all registered routes
2. Read the actual controller code for each API endpoint
3. Generate `docs/api-specs.md` documenting every `/api/*` route with:
   - HTTP method and URL
   - Authentication requirements
   - Request body / query parameters (with types and validation rules)
   - Response format (with example JSON)
   - Error responses
   - Rate limiting (if applicable)

Use this structure:

```markdown
# API Specification

> Auto-generated from the Laravel backend. This file is the single source of truth for the API contract between the backend and the mobile app.

Base URL: `http://{BACKEND_SLUG}.test` (development)

## Authentication

Endpoints marked with `Auth: required` need a Sanctum Bearer token:
```
Authorization: Bearer {token}
```

Obtain a token via `POST /api/v1/auth/login` or `POST /api/v1/auth/register`.

## Endpoints

### Auth

#### POST /api/v1/auth/login
(document from actual controller code)

#### POST /api/v1/auth/register
(document from actual controller code)

#### POST /api/v1/auth/logout
(document from actual controller code)

#### GET /api/v1/auth/user
(document from actual controller code)
```

**IMPORTANT**: Do not use a static template. Read the actual routes and controllers and generate accurate documentation from the real code.

## 11. Git Init

The `laravel new` command already initializes git. Commit the changes:

```bash
cd {BACKEND_SLUG}
git add -A
git commit -m "Initial scaffold with React starter kit, Sanctum API, and Laravel Boost"
```
