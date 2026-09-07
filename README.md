👋

# Tilt/Shift Config

Shared configuration for Tilt/Shift TypeScript projects.

- [Biome](https://biomejs.dev/) — lint + format
- [TypeScript](https://www.typescriptlang.org/) — shared base `tsconfig`
- [cspell](https://cspell.org/) — shared spelling dictionary

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

The base carries the formatter, linter, import-organizing, `vcs`, and `React`
global defaults. Add project-specific `files.includes` in your own config.

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

## cspell

Import the shared dictionary from your repo's `cspell` config:

```json
{
  "$schema": "https://raw.githubusercontent.com/streetsidesoftware/cspell/main/cspell.schema.json",
  "version": "0.2",
  "import": ["@tiltshift/config/cspell"]
}
```

The shared config defines the `tiltshift` dictionary — org, product, and stack
terms the bundled dictionaries miss. Add project-specific words to your own
config or a repo-local word list, and add a `cspell` dev dependency to run it.
