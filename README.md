# create-expo-app

Scaffold a production-ready React Native Expo app with a modern stack in one command.

An [Agent Skill](https://agentskills.io/) for AI coding agents (Claude Code, Cursor, Gemini CLI, Codex, and more).

## What It Does

This skill walks you through an interactive setup, then scaffolds a complete Expo project with everything wired up and ready to ship:

- **Tailwind CSS v4** via Uniwind + **HeroUI Native** component library
- **Zustand** + **React Query** + **MMKV** for state and storage
- **Expo Router** file-based routing
- **Reanimated** + **Gesture Handler** + **Bottom Sheet**
- **Jest** + **React Testing Library**
- Full **EAS Build** config (dev / preview / production)
- Generated **CLAUDE.md**, **DESIGN.md**, and **README.md**
- Utility scripts (image optimization, env syncing)
- Project-level agent skills auto-installed

### Optional integrations (asked during setup)

- **RevenueCat** — in-app purchases and subscriptions
- **Expo Notifications** — push notifications
- **Backend API** — env config and API client scaffolding

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
Scaffold a React Native project for a fitness tracker
```
```
Start a new mobile app called "My App"
```

The skill will ask you a series of questions:

1. **App name** — e.g., "My Cool App"
2. **Bundle ID** — suggested from the name, or specify your own
3. **In-app purchases?** — installs RevenueCat if yes
4. **Push notifications?** — installs expo-notifications if yes
5. **Backend API?** — configures env and API URL if yes
6. **Design vibe** — generates a color palette, tokens, and brand voice

Then it scaffolds everything into a new directory and you're ready to `npm start`.

## What Gets Created

```
my-cool-app/
├── src/
│   ├── app/              # Expo Router file-based routes
│   │   ├── _layout.tsx   # Provider hierarchy (wired up)
│   │   └── index.tsx     # 🚀 Ship! starter screen
│   ├── features/         # Feature modules go here
│   ├── components/       # Shared components
│   ├── hooks/            # Custom hooks
│   ├── lib/
│   │   ├── cn.ts         # clsx + tailwind-merge
│   │   ├── storage.ts    # MMKV wrapper
│   │   └── query.tsx     # React Query + NetInfo
│   └── global.css        # Tailwind + design tokens
├── scripts/
│   ├── sync-production-env.sh
│   └── optimize-images.sh
├── assets/images/        # App icons (from Expo template)
├── app.config.ts         # Expo config (plugins, experiments)
├── eas.json              # EAS Build profiles
├── env.ts                # Typed environment config
├── metro.config.js       # Uniwind wiring
├── tsconfig.json         # Strict + path aliases
├── CLAUDE.md             # AI agent project instructions
├── DESIGN.md             # Design tokens & brand guidelines
├── README.md             # Setup & release guide
├── .gitignore
└── .easignore
```

## Skill Structure

```
create-expo-app/
├── SKILL.md              # Interactive workflow instructions
├── scripts/
│   ├── sync-production-env.sh   # Template copied into projects
│   └── optimize-images.sh       # Template copied into projects
└── references/
    ├── wiring-guide.md          # Config file templates
    ├── CLAUDE-TEMPLATE.md       # CLAUDE.md template
    └── DESIGN-TEMPLATE.md       # DESIGN.md template
```

## License

MIT
