# DESIGN.md Template

Generate a DESIGN.md for the new project using this template. Replace all content with values derived from the user's design vibe answer.

**IMPORTANT**: The OKLCH values you choose here MUST be copied exactly into `src/global.css` `@theme` and `@layer theme` blocks. DESIGN.md is the single source of truth.

---

# {APP_NAME} Design System

> {One-sentence design philosophy derived from the user's vibe}

## Color Palette

All colors use OKLCH for perceptual uniformity. These values are wired directly into `src/global.css`.

### Core Colors

| Token | OKLCH | Hex (approx) | Usage |
|-------|-------|--------------|-------|
| `primary` | `oklch(...)` | `#...` | Main brand color, buttons, active states |
| `primary-foreground` | `oklch(...)` | `#...` | Text/icons on primary backgrounds |
| `accent` | `oklch(...)` | `#...` | Secondary actions, highlights |
| `accent-foreground` | `oklch(...)` | `#...` | Text/icons on accent backgrounds |

### Surface Colors

| Token | OKLCH | Hex (approx) | Usage |
|-------|-------|--------------|-------|
| `background` | `oklch(...)` | `#...` | App background |
| `foreground` | `oklch(...)` | `#...` | Primary text color |
| `surface` | `oklch(...)` | `#...` | Cards, elevated containers |
| `surface-light` | `oklch(...)` | `#...` | Subtle backgrounds, hover states |

### Semantic Colors

| Token | Usage |
|-------|-------|
| `success` | Confirmations, completed states |
| `warning` | Caution states, pending actions |
| `error` | Errors, destructive actions |
| `muted` | Disabled states, placeholder text |

## Typography

| Element | Font | Size | Weight | Tracking |
|---------|------|------|--------|----------|
| Display | System default | 32px | Bold (700) | -0.02em |
| Heading 1 | System default | 24px | Bold (700) | -0.01em |
| Heading 2 | System default | 20px | Semibold (600) | 0 |
| Body | System default | 16px | Regular (400) | 0 |
| Caption | System default | 13px | Regular (400) | 0.01em |

> Note: Prefer system fonts for performance. If custom fonts are needed, load via `expo-font` and update this table.

## Spacing & Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius` | `{radius}rem` | Default border radius |
| `radius-sm` | `{radius * 0.5}rem` | Small elements (chips, badges) |
| `radius-lg` | `{radius * 2}rem` | Large elements (cards, modals) |
| `radius-full` | `9999px` | Circular elements (avatars, pills) |

**Spacing scale**: Uses Tailwind's default 4px grid (p-1 = 4px, p-2 = 8px, p-4 = 16px, etc.)

## Brand Voice

> {Describe the copy tone based on the app's vibe}

**Guidelines:**
- {Guideline 1 — e.g., "Lead with benefits, not features"}
- {Guideline 2 — e.g., "Use active, encouraging language"}
- {Guideline 3 — e.g., "Keep microcopy under 8 words"}

**Examples:**
| Context | Instead of | Write |
|---------|-----------|-------|
| Empty state | "No items found" | "{Vibe-appropriate alternative}" |
| CTA button | "Submit" | "{Vibe-appropriate alternative}" |
| Error | "Error occurred" | "{Vibe-appropriate alternative}" |

## Dark / Light Mode

Strategy: {Describe the approach — e.g., "Dark-first with light mode support" or "Light-first, dark mode follows system preference"}

- Light mode tokens are defined in `@layer theme { :root { @variant light { ... } } }` in `global.css`
- Dark mode is the default / Light mode is the default (pick one)
- All custom colors should work in both modes
- Use HeroUI Native's built-in dark mode support for components

## Token → CSS Mapping

These tokens from the table above map directly to `src/global.css`:

```css
@theme {
  --radius: {radius}rem;
  --color-primary: oklch({primary});
  --color-primary-foreground: oklch({primary-foreground});
  --color-accent: oklch({accent});
  --color-surface: oklch({surface});
  --color-surface-light: oklch({surface-light});
}

@layer theme {
  :root {
    @variant light {
      --accent: oklch({accent});
      --accent-foreground: oklch({accent-foreground});
      --background: oklch({background});
      --foreground: oklch({foreground});
    }
  }
}
```
