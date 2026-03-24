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
{IF_PUSH:- **Expo Notifications** — Push notifications}

## What: Project Structure

```
src/
├── app/              # Expo Router file-based routes
├── features/         # Feature modules (screens, components, API hooks per feature)
├── components/       # Shared UI components
├── hooks/            # Shared custom React hooks
├── lib/              # Pre-configured utilities (query, storage, cn)
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

{IF_BACKEND:
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
