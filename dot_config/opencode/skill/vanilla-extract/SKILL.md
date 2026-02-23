---
name: vanilla-extract
description: Help developers work with vanilla-extract, a zero-runtime CSS-in-JS library
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
---

Use this skill to design and maintain vanilla-extract styling systems that keep themes and tokens centralized, co-locate component styles with their components, and lean on theme variables instead of ad-hoc values.

## Responsibilities

- Explain vanilla-extract concepts, patterns, and integration strategies.
- Help you implement and debug theme-first styling.
- Guide you through CSS-in-JS best practices tailored to vanilla-extract.
- Assist with design token authoring, theme configuration, and sprinkles utilities.
- Review existing vanilla-extract code and highlight issues before they ship.

## When to Use

- You are bootstrapping vanilla-extract in a new project.
- You are building or refactoring styled components.
- You need to configure themes, design tokens, or sprinkles.
- You are debugging CSS-in-JS regressions.
- You want to align an existing codebase with vanilla-extract conventions.

## Workflow Priorities

- Prefer theme variables everywhere possible; avoid raw literals once a token exists.
- Store **all design tokens** in a dedicated `tokens.ts` (non-`.css.ts`) file.
- Define **all themes** inside a single `themes.css.ts` file and interpolate tokens into each theme value.
- Keep component styles inside the component’s own `.css.ts` file to stay co-located with the JSX/TSX logic.
- Follow the project’s naming conventions; vanilla-extract does not impose any, so mirror the repository style.

## Common Patterns

### Theme-First Token Pipeline

1. Author tokens in a standalone TypeScript module.
2. Import the tokens into the single theme file and call `createTheme` once per theme.
3. Export both the theme contract and the theme class for downstream styles.

```ts
// tokens/themeTokens.ts
export const colorTokens = {
  brand: "#3B82F6",
  accent: "#F97316",
  surface: "#0F172A",
  text: "#F1F5F9",
};

// themes/themes.css.ts
import { createTheme } from "@vanilla-extract/css";
import { colorTokens } from "../tokens/themeTokens";

export const [lightThemeClass, lightThemeVars] = createTheme({
  color: {
    brand: colorTokens.brand,
    accent: colorTokens.accent,
    surface: colorTokens.surface,
    text: colorTokens.text,
  },
});
```

### Component-Co-Located Styles

1. Create a `.css.ts` file adjacent to the component.
2. Import the exported theme vars and reference them directly.
3. Export `style` objects and consume them in the component file.

```ts
// components/Button/Button.css.ts
import { style } from "@vanilla-extract/css";
import { lightThemeVars } from "../../themes/themes.css";

export const button = style({
  backgroundColor: lightThemeVars.color.brand,
  color: lightThemeVars.color.text,
  borderRadius: 8,
  selectors: {
    "&:hover": { backgroundColor: lightThemeVars.color.accent },
  },
});
```

## Common Issues and Remedies

### Importing Non-VE Code into `.css.ts`

- **Symptom:** Build errors mention unsupported runtime code.
- **Remedy:** Re-export data from plain `.ts` files and only import primitive objects/functions into `.css.ts` modules.

> Warning: Do not import React hooks, `Date`, or complex utilities into `.css.ts` files—the bundler strips them, causing runtime failures.

### Multiple Theme Files

- **Symptom:** Theme overrides fall out of sync across files.
- **Remedy:** Consolidate every `createTheme` invocation into the single `themes.css.ts` module so new tokens propagate predictably.

### Raw Values Sneaking In

- **Symptom:** Designers update tokens but components stay outdated.
- **Remedy:** Search for literals (e.g., `'#3B82F6'`) inside component styles and replace them with `themeVars` entries.

> Warning: Raw values also break dark-mode parity because they bypass the active theme contract.

### Sprinkles Type Drift

- **Symptom:** TypeScript stops flagging invalid responsive props.
- **Remedy:** Export the `Sprinkles` type from the sprinkles module and apply it to component props to keep compiler coverage.

## Key API Reference

### `createVar` and `assignVars`

Use `createVar` to declare custom properties and `assignVars` to batch-apply maps of values.

```ts
import { createVar, style, assignVars } from "@vanilla-extract/css";

const spacingVar = createVar();
// Provide a stack layout that references the custom property instead of a literal.
export const stack = style({ gap: spacingVar });

// Override the spacing by assigning the variable to a concrete value.
export const stackTight = assignVars({ [spacingVar]: "0.5rem" });
```

### `createTheme`

Creates a theme class plus a vars object. Keep all calls inside the dedicated theme file.

```ts
import { createTheme } from "@vanilla-extract/css";

// Build every theme from shared tokens inside the single themes.css.ts file.
export const [themeClass, themeVars] = createTheme({ spacing: { m: "1rem" } });
```

### `style`

Defines a single CSS class. Co-locate each `style` with its component.

```ts
// Card styles rely on theme spacing to avoid hard-coded values.
export const card = style({ padding: themeVars.spacing.m, borderRadius: 12 });
```

### `styleVariants`

Generates multiple related classes without branching logic.

```ts
import { styleVariants } from "@vanilla-extract/css";

// Map variant names to style objects without branching logic.
export const badge = styleVariants({
  info: { background: themeVars.color.brand },
  warn: { background: themeVars.color.accent },
});
```

### `globalStyle`

Apply project-wide resets or tag styles sparingly.

```ts
import { globalStyle } from "@vanilla-extract/css";

// Apply a project-wide reset that still respects theme colors.
globalStyle("body", {
  margin: 0,
  backgroundColor: themeVars.color.surface,
  color: themeVars.color.text,
});
```

## References

- [createTheme documentation](https://vanilla-extract.style/documentation/api/create-theme/)
- [style and styleVariants documentation](https://vanilla-extract.style/documentation/api/style/)
- [Global styles API](https://vanilla-extract.style/documentation/api/global-style/)
