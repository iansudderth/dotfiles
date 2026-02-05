---
name: vanilla-extract
description: Help developers work with vanilla-extract, a zero-runtime CSS-in-JS library
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
---

## What I do

- Explain vanilla-extract concepts and patterns
- Help implement and debug vanilla-extract styling
- Guide on best practices for CSS-in-JS with vanilla-extract
- Assist with theme configuration and design tokens
- Review vanilla-extract code for issues

## When to use me

Use this when you are:

- Setting up vanilla-extract in a new project
- Building styled components with vanilla-extract
- Configuring themes or design systems
- Debugging CSS-in-JS issues
- Refactoring existing styles to vanilla-extract
- Working with sprinkles or other vanilla-extract utilities

## Core concepts I can help with

- Theme configuration and design tokens

- We want to rely on theming as much as possible, i.e. use theme variables to build styles whenever you can.
- We also want our design tokens stored in a file separate from our `.css.ts` files, because there's issues importing non-vanilla-extract code from those files.  You should build a theme by interpolating the tokens into the theme values.
- All themes should be in a single file, all tokens in another single file.  Styles should live with their components in the same file.
- Follow the naming conventions of the project, there is no reliance on conventions for this library.
