---
name: go
description: patterns for developing go applications
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: frontend
---

# Go Development

## Development Principles & Patterns

## Preferred Libraries

- In `go`, we aim to use the standard library as much as possible.
- For services that need an http router, use `chi`

## Testing Patterns

- use the standard library's `test` module, do not get an external testing framework.
- The `testify` library provides a lot of useful helpful utilities for testing, use this for comparing outputs.
