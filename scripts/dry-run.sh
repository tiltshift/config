#!/usr/bin/env bash

set -uo pipefail

usage() {
	printf 'Usage: %s <group/rule | all> [--markdown]\n' "$(basename "$0")" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
	usage
	exit 2
fi

rule="$1"
markdown=false

if [[ $# -eq 2 ]]; then
	if [[ "$2" != "--markdown" ]]; then
		usage
		exit 2
	fi
	markdown=true
fi

if [[ "$rule" != "all" && "$rule" != */* ]]; then
	usage
	exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$(cd -- "$script_dir/.." && pwd)"
repos_file="$package_dir/.dry-run-repos"

if [[ ! -f "$repos_file" ]]; then
	printf 'Missing checkout list: %s\n' "$repos_file" >&2
	exit 1
fi

temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/tiltshift-config-dry-run.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT

if [[ "$markdown" == true ]]; then
	printf '| Repo | Rule | Count |\n'
	printf '| --- | --- | ---: |\n'
fi

failed=0
repo_total=0

while IFS= read -r repo_path || [[ -n "$repo_path" ]]; do
	repo_path="${repo_path%$'\r'}"
	if [[ -z "$repo_path" || "$repo_path" == \#* ]]; then
		continue
	fi

	repo_total=$((repo_total + 1))

	if [[ "$repo_path" == '~/'* ]]; then
		repo_path="$HOME/${repo_path#\~/}"
	elif [[ "$repo_path" != /* ]]; then
		repo_path="$package_dir/$repo_path"
	fi

	if [[ ! -d "$repo_path" ]]; then
		printf 'Missing checkout: %s\n' "$repo_path" >&2
		failed=1
		continue
	fi

	repo_path="$(cd -- "$repo_path" && pwd)"
	repo_name="$(basename "$repo_path")"
	report_file="$temp_dir/$repo_total.json"
	error_file="$temp_dir/$repo_total.err"

	if [[ "$rule" == "all" ]]; then
		(
			cd -- "$repo_path" || exit 1
			npx biome lint "--config-path=$package_dir/biome.json" --reporter=json --max-diagnostics=none .
		) >"$report_file" 2>"$error_file"
	else
		(
			cd -- "$repo_path" || exit 1
			npx biome lint "--only=$rule" --reporter=json --max-diagnostics=none .
		) >"$report_file" 2>"$error_file"
	fi

	biome_exit=$?
	diagnostic_count="$(node -e '
		const fs = require("node:fs");
		const report = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
		if (report.command !== "lint" || !Array.isArray(report.diagnostics)) process.exit(1);
		process.stdout.write(String(report.diagnostics.length));
	' "$report_file" 2>/dev/null)"
	parse_exit=$?

	if [[ $parse_exit -ne 0 ]]; then
		printf 'Biome failed in %s (exit %s).\n' "$repo_path" "$biome_exit" >&2
		if [[ -s "$error_file" ]]; then
			cat "$error_file" >&2
		fi
		failed=1
		continue
	fi

	if [[ "$markdown" == true ]]; then
		repo_cell="${repo_name//|/\\|}"
		printf '| %s | %s | %s |\n' "$repo_cell" "$rule" "$diagnostic_count"
	else
		printf '%s  %s  %s\n' "$repo_name" "$rule" "$diagnostic_count"
	fi
done <"$repos_file"

if [[ $repo_total -eq 0 ]]; then
	printf 'No checkouts listed in %s\n' "$repos_file" >&2
	exit 1
fi

exit "$failed"
