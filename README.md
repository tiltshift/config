👋

# Tilt/Shift Config

Shared configuration for Tilt/Shift TypeScript projects.

- [Biome](https://biomejs.dev/) — lint + format
- [TypeScript](https://www.typescriptlang.org/) — shared base `tsconfig`
- [cspell](https://cspell.org/) — shared spelling dictionary

## Installation

```bash
yarn add --dev @tiltshift/config@^4.0.0
```

## Biome

Add a `biome.json` to your repo that extends the shared base:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.5.13/schema.json",
  "extends": ["@tiltshift/config/biome"]
}
```

### Biome plugins

This package does not currently ship any Biome plugins. Biome 2.5.12 resolves a
relative `plugins` path from the consumer repo, even when an extended config
under `node_modules` provides the entry. If this package adds a plugin later,
the package must include its GritQL file and each consumer must register that
installed file explicitly in its own `plugins` array. Extending the base cannot
activate it.

GritQL plugins cannot inspect comment trivia in Biome 2.5.12. Enforcing the ban
on Linear issue IDs such as `TS-123` in source comments remains a CI script
item, not a Biome plugin.

### Change the shared lint policy

Keep this maintenance workflow with the shared config it governs. A consumer
template may direct contributors here, but it cannot own the fleet dry run,
package release, or suppression policy for existing repositories.

1. When a review catches something a machine could catch, file a TS issue with
   the `config` label. Link the review comment and include the code snippet and
   proposed rule.
2. Add the rule here and put fleet dry-run counts for each repo in the config
   PR.
3. For a small count, set the rule to `error` and fix the hits in the consumer
   bump PR. For a large count, run
   `biome lint --suppress --reason "predates the rule"` in the bump PR so new
   code is held to the rule and the suppressions form the backlog.
4. Release the config. Dependabot opens the consumer bump PRs, where
   `yarn check` shows the fallout.
5. Revisit a rule that keeps getting suppressed. Do not accumulate
   suppressions for it.

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

Pass `all` to lint every checkout with this package's `biome.json`, honoring
each checkout's `.gitignore` so build output is not counted. Add `--markdown`
to print a table ready for a pull request body:

```bash
yarn dry-run all --markdown
```

Both modes run this repository's pinned Biome, so counts come from the version
the shared base targets rather than whatever each checkout resolves.

The script exits with an error if a listed checkout is missing, Biome cannot
produce a JSON lint report there, or Biome processes no files. A lint run that
finds diagnostics still succeeds and reports their count.

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
