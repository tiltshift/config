👋

# Tilt/Shift Config

Shared configuration for Tilt/Shift TypeScript projects.

- [Biome](https://biomejs.dev/) — lint + format
- [TypeScript](https://www.typescriptlang.org/) — shared base `tsconfig`
- [Codebook](https://github.com/blopker/codebook) — shared spelling dictionary

## Installation

1. Add this repo as a submodule:

```bash
git submodule add https://github.com/tiltshift/config.git packages/config
```

2. Add the workspace, resolution, and development dependency to the root
   `package.json`:

```json
{
	"workspaces": [
		"packages/*"
	],
	"resolutions": {
		"@tiltshift/config": "workspace:*"
	},
	"devDependencies": {
		"@tiltshift/config": "workspace:*"
	}
}
```

3. Install dependencies:

```bash
yarn install
```

### Repos that are consumed as submodules

Any repo that other repos add as a submodule, including this one and
`tiltshift/schema`, does three things:

- Sets `"root": false` in its `biome.json`.
- Passes `--config-path=biome.json` to every `biome` command in its
  `package.json` scripts.
- Commits `.zed/settings.json` with `lsp.biome.settings.config_path` set to
  `biome.json`.

Biome 2.5 exits with `Found a nested root configuration` when it finds a second
root config inside a consumer. It also ignores a nested config that has no root
above it unless the path is given explicitly. Consumers need no exclusion:
their `biome.json` is the single root, and the submodule's files are linted and
formatted under it in the editor and on the CLI.

## Biome

Add a `biome.json` to your repo that extends the shared base:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.5.13/schema.json",
  "extends": ["@tiltshift/config/biome"]
}
```

### Biome plugins

This package does not currently ship any Biome plugins. The submodule sits at a
fixed path, so a consumer registers a shared plugin as
`./packages/config/lint/<name>.grit` in its own `plugins` array. Extending the
base still cannot activate a plugin.

GritQL plugins cannot inspect comment trivia in Biome 2.5.12. Enforcing the ban
on Linear issue IDs such as `TS-123` in source comments remains a CI script
item, not a Biome plugin.

### Change the shared lint policy

Keep this maintenance workflow with the shared config it governs. A consumer
template may direct contributors here, but it cannot own the Biome rule dry
run or suppression policy for existing repositories.

1. When a review catches something a machine could catch, file a TS issue with
   the `config` label. Link the review comment and include the code snippet and
   proposed rule.
2. Add the rule here and put Biome rule dry-run counts for each repo in the
   config PR.
3. For a small count, set the rule to `error` and fix the hits in the consumer
   bump PR. For a large count, run
   `biome lint --suppress --reason "predates the rule"` in the bump PR so new
   code is held to the rule and the suppressions form the backlog.
4. Merge the config PR. Dependabot's `gitsubmodule` updates open the consumer
   bump PRs, where `yarn check` shows the fallout.
5. Revisit a rule that keeps getting suppressed. Do not accumulate
   suppressions for it.

### Biome rule dry runs

A dry run counts what one Biome rule would flag in every Tilt/Shift repo that
extends this config, before the rule ships. Put the counts in the config PR.

**Set up once.** List the checkouts in a gitignored `.dry-run-repos` file at
this repo's root, one path per line. Paths can be absolute, start with `~/`,
or be relative to this repo. Blank lines and `#` comments are skipped.

```text
../code-glue
/path/to/chat-builder
```

**Count one rule:**

```bash
yarn dry-run correctness/noUnusedVariables
```

**Count every rule in this package's `biome.json`,** printed as a table for
the PR body:

```bash
yarn dry-run all --markdown
```

Both modes run this repo's pinned Biome, so counts match the base rather than
whatever each checkout resolves. The `all` mode honors each checkout's
`.gitignore`, so build output is not counted.

A run fails if a listed checkout is missing, Biome cannot produce a JSON
report there, or Biome processes no files. Diagnostics alone do not fail the
run; they are the count.

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

## Codebook

Spell checking in Zed uses [Codebook](<https://github.com/blopker/codebook>).

Point Codebook at the shared Tilt/Shift word list in the submodule from the
project's `.zed/settings.json`:

```json
{
  "lsp": {
    "codebook": {
      "initialization_options": {
        "globalConfigPath": "packages/config/codebook.toml"
      }
    }
  }
}
```
