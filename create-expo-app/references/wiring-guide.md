# Wiring Guide

Exact file contents for all configuration and library files. Copy these into the new project, replacing placeholders as indicated.

## metro.config.js

```javascript
const { getDefaultConfig } = require('expo/metro-config');
const { withUniwindConfig } = require('uniwind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
});
```

## tsconfig.json

```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "paths": {
      "@/*": ["./src/*"],
      "@/assets/*": ["./assets/*"]
    }
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ]
}
```

## eslint.config.js

```javascript
const { defineConfig } = require('eslint/config');
const expoConfig = require("eslint-config-expo/flat");

module.exports = defineConfig([
  expoConfig,
  {
    ignores: ["dist/*"],
  }
]);
```

## src/global.css

Template — replace the `@theme` values with tokens from DESIGN.md:

```css
@import "tailwindcss";
@import "uniwind";
@import "heroui-native/styles";

@source "../node_modules/heroui-native/lib";

@theme {
  --radius: 0.25rem;

  /* Replace these with values from DESIGN.md */
  --color-primary: oklch(/* primary */);
  --color-primary-foreground: oklch(/* primary-foreground */);
  --color-accent: oklch(/* accent */);
  --color-surface: oklch(/* surface */);
  --color-surface-light: oklch(/* surface-light */);
}

@layer theme {
  :root {
    @variant light {
      --accent: oklch(/* accent */);
      --accent-foreground: oklch(/* accent-foreground */);
      --background: oklch(/* background */);
      --foreground: oklch(/* foreground */);
    }
  }
}
```

## src/lib/cn.ts

```typescript
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

## src/lib/storage.ts

```typescript
import { createMMKV } from 'react-native-mmkv';

export const storage = createMMKV();

export const Storage = {
  set: (key: string, value: string | number | boolean) => {
    storage.set(key, value);
  },
  getString: (key: string) => storage.getString(key),
  getNumber: (key: string) => storage.getNumber(key),
  getBoolean: (key: string) => storage.getBoolean(key),
  delete: (key: string) => storage.remove(key),
  contains: (key: string) => storage.contains(key),
  clearAll: () => storage.clearAll(),
};
```

## src/lib/query.tsx

```typescript
import NetInfo from '@react-native-community/netinfo';
import {
  onlineManager,
  QueryClient,
  QueryClientProvider,
} from '@tanstack/react-query';

onlineManager.setEventListener((setOnline) => {
  return NetInfo.addEventListener((state) => {
    setOnline(state.isConnected !== false);
  });
});

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,
      retry: 2,
    },
  },
});

export function QueryProvider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}
```

## src/app/_layout.tsx

```tsx
import '../global.css';

import { Stack } from 'expo-router';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import {
  SafeAreaProvider,
  SafeAreaListener,
} from 'react-native-safe-area-context';
import { HeroUINativeProvider } from 'heroui-native';
import { Uniwind } from 'uniwind';

import { QueryProvider } from '@/lib/query';

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <SafeAreaListener
          onChange={({ insets }) => {
            Uniwind.updateInsets(insets);
          }}
        >
          <HeroUINativeProvider>
            <QueryProvider>
              <Stack
                screenOptions={{
                  headerShown: false,
                }}
              />
            </QueryProvider>
          </HeroUINativeProvider>
        </SafeAreaListener>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
```

## src/app/index.tsx

```tsx
import { Text, View } from 'react-native';

export default function HomeScreen() {
  return (
    <View className="flex-1 items-center justify-center bg-background">
      <Text style={{ fontSize: 64 }}>🚀</Text>
      <Text className="mt-4 text-2xl font-bold text-foreground">Ship!</Text>
    </View>
  );
}
```

## .gitignore

```
# dependencies
node_modules/

# Expo
.expo/
dist/
web-build/
expo-env.d.ts

# Native
.kotlin/
*.orig.*
*.jks
*.p8
*.p12
*.key
*.mobileprovision

# Metro
.metro-health-check*

# debug
npm-debug.*
yarn-debug.*
yarn-error.*

# macOS
.DS_Store
*.pem

# local env files
.env*
!.env.example

# typescript
*.tsbuildinfo

app-example

# generated native folders
/ios
/android

# local build artifacts
*.ipa

# tools
tools/.env
```

## .easignore

```
# dependencies (EAS installs from package.json)
node_modules/

# Expo
.expo/
dist/
web-build/
expo-env.d.ts

# Native (regenerated by EAS)
.kotlin/
*.orig.*
*.jks
*.p8
*.p12
*.key
*.mobileprovision
/ios
/android

# Metro
.metro-health-check*

# debug
npm-debug.*
yarn-debug.*
yarn-error.*

# macOS
.DS_Store
*.pem

# local env files
.env*
!.env.example

# typescript
*.tsbuildinfo

app-example

# ── Not needed for EAS builds ──

# Git history
.git/

# Design assets & screenshots
design/

# Local dev tools
tools/

# Editor / agent config
.vscode/
.claude/
.agents/
.kiro/

# Documentation
docs/
```
