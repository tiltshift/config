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

### Fleet dry runs

Create a gitignored `.dry-run-repos` file in this repository with one checkout
path per line. Paths can be absolute, start with `~/`, or be relative to this
repository. Blank lines and lines that start with `#` are ignored.

```text
../code-glue
/path/to/chat-builder
```

Count diagnostics from one rule in every checkout:

```bash
yarn dry-run correctness/noUnusedVariables
```

Pass `all` to lint every checkout with this package's `biome.json`. Add
`--markdown` to print a table ready for a pull request body:

```bash
yarn dry-run all --markdown
```

The script exits with an error if a listed checkout is missing or Biome cannot
produce a JSON lint report there. A lint run that finds diagnostics still
succeeds and reports their count.

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
