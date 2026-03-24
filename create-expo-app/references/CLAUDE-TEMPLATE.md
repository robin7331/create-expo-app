# CLAUDE.md Template

Generate a CLAUDE.md for the new project using this template. Replace all `{PLACEHOLDERS}` with actual values from the user's answers and the scaffolded project.

---

## What: Technology Stack

- **Expo SDK** with React Native — Managed React Native development
- **TypeScript** — Strict type safety throughout
- **Expo Router** — File-based routing (like Next.js)
- **TailwindCSS v4** via Uniwind — Utility-first styling for React Native
- **HeroUI Native** — Pre-built accessible component library
- **Zustand** — Lightweight global state management
- **React Query** — Server state and data fetching
- **TanStack Form + Zod** — Type-safe form handling and validation
- **MMKV** — Encrypted local storage
- **Jest + React Testing Library** — Unit testing
{IF_IAP:- **RevenueCat** — In-app purchases and subscriptions}

## What: Project Structure

```
src/
├── app/              # Expo Router file-based routes
├── features/         # Feature modules (screens, components, API hooks per feature)
├── components/       # Shared UI components
├── hooks/            # Shared custom React hooks
├── lib/              # Pre-configured utilities (query, storage, cn{IF_LARAVEL:, api})
└── global.css        # TailwindCSS + Uniwind configuration & design tokens

Root Files:
├── env.ts            # Typed environment config
├── app.config.ts     # Expo configuration
├── eas.json          # EAS Build profiles
├── DESIGN.md         # Design tokens, palette, typography, brand voice
└── README.md         # Setup & release guide
```

## How: Development Workflow

**Essential Commands:**
```bash
npm start              # Start dev server
npm run ios            # Run on iOS simulator
npm run android        # Run on Android emulator
npm run lint           # ESLint check
npm run type-check     # TypeScript validation
npm run test           # Run Jest tests
npm run check-all      # All quality checks
```

**Building & Releasing:**
```bash
npm run build:dev              # Dev client build
npm run build:preview          # Internal testing build
npm run build:production       # App Store / Play Store build
npm run build:production:local # Local production build
npm run submit:ios             # Submit .ipa to App Store Connect
```

{IF_LARAVEL:
## What: Backend API (Laravel)

This app communicates with a Laravel backend located at `../{BACKEND_SLUG}/`.

### Cross-Project Workflows

- When asked to "check the backend", "look at the backend code", or "check the API", navigate to `../{BACKEND_SLUG}/`.
- When asked to "create a GitHub issue in the backend" or "create an issue for the backend", run `gh issue create` from within the `../{BACKEND_SLUG}/` directory.
- When asked about "the backend" or "the API", this refers to the Laravel project at `../{BACKEND_SLUG}/`.

### API Contract

The file `../{BACKEND_SLUG}/docs/api-specs.md` is the **single source of truth** for the API contract. When implementing new API calls, always reference this file for endpoint URLs, request/response formats, and authentication requirements.

When asked about "api specs" or "the API contract", this refers to `../{BACKEND_SLUG}/docs/api-specs.md`.

### API Base URL

- Development: `http://{BACKEND_SLUG}.test` (Laravel Herd)
- Configured in `env.ts` as `API_URL`

### Authentication

{IF_SANCTUM:The app authenticates via Sanctum API tokens. The token is stored in MMKV and attached as a `Bearer` token to all requests via `src/lib/api.ts`. Auth logic lives in `src/features/auth/`.}

### Conventions

- **snake_case on the wire**: The backend uses snake_case. Map to camelCase at the API boundary in `src/features/`
- **API client**: All requests go through `src/lib/api.ts` which handles auth tokens and error parsing
- **Response types**: Define response types in the relevant feature's `types.ts` file
}

{IF_BACKEND_NO_LARAVEL:
## What: Backend API

The app communicates with a backend API at `{API_URL}`.

- **Imports**: Always use `@/` prefix, never relative imports
- **Response conventions**: All API responses return JSON
- **snake_case on the wire**: If the backend uses snake_case, map to camelCase at the API boundary in `src/features/backend/`
}

## How: Key Patterns

- **Create features**: New folder in `src/features/[your-feature]/` with screens, components, API hooks
- **Add routes**: Create files in `src/app/` (file-based routing)
- **Forms**: Use TanStack Form + Zod for type-safe form handling and validation
- **Data fetching**: Use React Query with query key factories
- **Global state**: Use Zustand stores — persistent stores use MMKV via `zustand/middleware/persist`
- **Styling**: Tailwind classes via `className` prop (powered by Uniwind). Use `cn()` from `@/lib/cn` for conditional classes
- **Components**: Use HeroUI Native for pre-built components (Button, Card, TextField, Dialog, etc.)
- **Storage**: Use MMKV via `@/lib/storage` for persistent data (not AsyncStorage)
- **Imports**: Always use `@/` prefix, never relative imports

## How: Essential Rules

- Always use absolute imports: `@/components/button`, `@/lib/storage`
- Follow feature-based structure: `src/features/[name]/`
- Use TanStack Form for forms (not react-hook-form)
- Use MMKV storage for persistent data (not AsyncStorage)
- Use EAS Build for production builds
- Prefix env vars with `EXPO_PUBLIC_*` for app access
- Do NOT modify `android/` or `ios/` directly (use Expo config plugins)
- Design tokens live in `DESIGN.md` and are wired into `src/global.css`

## What: Design System

See [DESIGN.md](DESIGN.md) for the complete design token reference:
- Color palette (OKLCH values wired into global.css)
- Typography scale
- Spacing & border radius
- Brand voice guidelines
- Dark/light mode strategy
