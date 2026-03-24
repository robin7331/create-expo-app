# Auth Client Guide

Exact file contents for the Expo app's auth client when a Laravel backend with Sanctum is selected. Referenced by SKILL.md.

## src/lib/api.ts

Fetch wrapper that automatically attaches the Sanctum Bearer token from MMKV storage.

```typescript
import { Env } from '../../env';
import { Storage } from './storage';

const AUTH_TOKEN_KEY = 'auth_token';

export function getAuthToken(): string | undefined {
  return Storage.getString(AUTH_TOKEN_KEY);
}

export function setAuthToken(token: string): void {
  Storage.set(AUTH_TOKEN_KEY, token);
}

export function clearAuthToken(): void {
  Storage.delete(AUTH_TOKEN_KEY);
}

export async function apiRequest<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const token = getAuthToken();
  const url = `${Env.API_URL}${path}`;

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    ...((options.headers as Record<string, string>) ?? {}),
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(url, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new ApiError(
      response.status,
      error.message ?? 'Request failed',
      error.errors,
    );
  }

  return response.json();
}

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
    public errors?: Record<string, string[]>,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}
```

## src/features/auth/types.ts

```typescript
export interface User {
  id: number;
  name: string;
  email: string;
  email_verified_at: string | null;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  name: string;
  email: string;
  password: string;
  password_confirmation: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}
```

## src/features/auth/api.ts

```typescript
import { apiRequest, setAuthToken, clearAuthToken } from '@/lib/api';
import type {
  AuthResponse,
  LoginRequest,
  RegisterRequest,
  User,
} from './types';

export async function login(data: LoginRequest): Promise<AuthResponse> {
  const response = await apiRequest<AuthResponse>('/api/v1/auth/login', {
    method: 'POST',
    body: JSON.stringify(data),
  });
  setAuthToken(response.token);
  return response;
}

export async function register(data: RegisterRequest): Promise<AuthResponse> {
  const response = await apiRequest<AuthResponse>('/api/v1/auth/register', {
    method: 'POST',
    body: JSON.stringify(data),
  });
  setAuthToken(response.token);
  return response;
}

export async function logout(): Promise<void> {
  try {
    await apiRequest('/api/v1/auth/logout', { method: 'POST' });
  } finally {
    clearAuthToken();
  }
}

export async function getUser(): Promise<User> {
  return apiRequest<User>('/api/v1/auth/user');
}
```

## src/features/auth/store.ts

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { storage } from '@/lib/storage';
import type { User } from './types';
import { getAuthToken } from '@/lib/api';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  setUser: (user: User) => void;
  clearUser: () => void;
  hydrate: () => void;
}

const mmkvStorage = {
  getItem: (name: string) => storage.getString(name) ?? null,
  setItem: (name: string, value: string) => storage.set(name, value),
  removeItem: (name: string) => storage.remove(name),
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      setUser: (user) => set({ user, isAuthenticated: true }),
      clearUser: () => set({ user: null, isAuthenticated: false }),
      hydrate: () => {
        const token = getAuthToken();
        if (!token) {
          set({ user: null, isAuthenticated: false });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => mmkvStorage),
    },
  ),
);
```

## src/app/login.tsx

Minimal functional login screen. Styled with design tokens from global.css.

```tsx
import { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  Pressable,
  ActivityIndicator,
} from 'react-native';
import { router } from 'expo-router';
import { login } from '@/features/auth/api';
import { useAuthStore } from '@/features/auth/store';
import { ApiError } from '@/lib/api';

export default function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const setUser = useAuthStore((s) => s.setUser);

  const handleLogin = async () => {
    setError('');
    setLoading(true);
    try {
      const { user } = await login({ email, password });
      setUser(user);
      router.replace('/');
    } catch (e) {
      if (e instanceof ApiError) {
        setError(e.message);
      } else {
        setError('Something went wrong');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 justify-center px-6 bg-background">
      <Text className="text-3xl font-bold text-foreground mb-8">Sign in</Text>

      {error ? <Text className="text-error mb-4">{error}</Text> : null}

      <TextInput
        className="bg-surface text-foreground px-4 py-3 rounded-lg mb-3"
        placeholder="Email"
        placeholderTextColor="#999"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
      />

      <TextInput
        className="bg-surface text-foreground px-4 py-3 rounded-lg mb-6"
        placeholder="Password"
        placeholderTextColor="#999"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />

      <Pressable
        className="bg-primary py-3 rounded-lg items-center"
        onPress={handleLogin}
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="white" />
        ) : (
          <Text className="text-primary-foreground font-semibold text-base">
            Sign in
          </Text>
        )}
      </Pressable>
    </View>
  );
}
```

## Updated src/app/_layout.tsx

When auth is enabled, the root layout should check auth state and redirect accordingly. Update the layout to wrap the Stack with an auth check:

```tsx
import '../global.css';

import { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import {
  SafeAreaProvider,
  SafeAreaListener,
} from 'react-native-safe-area-context';
import { HeroUINativeProvider } from 'heroui-native';
import { Uniwind } from 'uniwind';

import { QueryProvider } from '@/lib/query';
import { useAuthStore } from '@/features/auth/store';
import { getAuthToken } from '@/lib/api';

function AuthGuard({ children }: { children: React.ReactNode }) {
  const segments = useSegments();
  const router = useRouter();
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);

  useEffect(() => {
    const onLoginPage = segments[0] === 'login';

    if (!isAuthenticated && !onLoginPage) {
      router.replace('/login');
    } else if (isAuthenticated && onLoginPage) {
      router.replace('/');
    }
  }, [isAuthenticated, segments]);

  return <>{children}</>;
}

export default function RootLayout() {
  const hydrate = useAuthStore((s) => s.hydrate);

  useEffect(() => {
    hydrate();
  }, []);

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
              <AuthGuard>
                <Stack
                  screenOptions={{
                    headerShown: false,
                  }}
                />
              </AuthGuard>
            </QueryProvider>
          </HeroUINativeProvider>
        </SafeAreaListener>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
```

This layout:
- Hydrates auth state from MMKV on mount
- Redirects to `/login` if not authenticated
- Redirects to `/` if authenticated and on the login page
