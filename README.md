👋

# Tilt/Shift Config

Shared configuration for Tilt/Shift TypeScript projects.

- [Biome](https://biomejs.dev/) — lint + format (current direction)
- [TypeScript](https://www.typescriptlang.org/) — shared base `tsconfig`
- [ESLint](https://eslint.org/) + [Prettier](https://prettier.io/) — kept for repos not yet migrated to Biome

## Installation

```bash
yarn add --dev @tiltshift/config
```

## Biome

Add a `biome.json` to your repo that extends the shared base:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.3.11/schema.json",
  "extends": ["@tiltshift/config/biome"]
}
```

The base carries formatter, linter, and import-organizing defaults only. Add
project-specific `files.includes`, `vcs`, and any React globals in your own
config.

## TypeScript

Extend the shared base from your root `tsconfig.json`:

```json
{
  "extends": "@tiltshift/config/tsconfig"
}
```

Each app or package extends the repo root and overrides only what its platform
needs — JSX for web, module settings for React Native/Expo, node types for
servers. Overrides are the exception.

## ESLint + Prettier (transition)

Still exported while repos migrate to Biome. In your `package.json`:

```json
{
  "prettier": "@tiltshift/config/prettier"
}
```

Add a file `eslint.config.mjs` with the following contents:

```
import tiltShiftConfig from '@tiltshift/config/eslint'

export default tiltShiftConfig
```
