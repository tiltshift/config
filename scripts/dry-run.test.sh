#!/usr/bin/env bash

set -euo pipefail

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	exit 1
}

test_dir="$(mktemp -d "${TMPDIR:-/tmp}/tiltshift-config-dry-run-test.XXXXXX")"
trap 'rm -rf "$test_dir"' EXIT
test_dir="$(cd "$test_dir" && pwd)"

package_dir="$test_dir/package with spaces"
biome_bin="$package_dir/node_modules/.bin/biome"
repo_one="$test_dir/repo-one"
repo_two="$test_dir/repo-two"
repo_fail="$test_dir/repo-fail"
repo_empty="$test_dir/repo-empty"

mkdir -p "$package_dir/scripts" "$package_dir/node_modules/.bin" "$repo_one" "$repo_two" "$repo_fail" "$repo_empty"
cp scripts/dry-run.sh "$package_dir/scripts/dry-run.sh"
cp biome.json "$package_dir/biome.json"

cat >"$biome_bin" <<'EOF'
#!/usr/bin/env bash

printf '%s\t%s\n' "$(basename "$PWD")" "$*" >>"$DRY_RUN_ARGS_LOG"

case "$(basename "$PWD")" in
	repo-one)
		printf '%s\n' '{"summary":{"changed":0,"unchanged":3},"diagnostics":[{},{}],"command":"lint"}'
		exit 1
		;;
	repo-two)
		printf '%s\n' '{"summary":{"changed":0,"unchanged":3},"diagnostics":[],"command":"lint"}'
		;;
	repo-empty)
		printf '%s\n' '{"summary":{"changed":0,"unchanged":0},"diagnostics":[],"command":"lint"}'
		exit 1
		;;
	*)
		printf 'runner error\n' >&2
		exit 2
		;;
esac
EOF
chmod +x "$biome_bin" "$package_dir/scripts/dry-run.sh"

export DRY_RUN_ARGS_LOG="$test_dir/args.log"

printf '%s\n%s\n' "$repo_one" "$repo_two" >"$package_dir/.dry-run-repos"
plain_output="$("$package_dir/scripts/dry-run.sh" correctness/noUnusedVariables)"
expected_plain="$(printf 'repo-one  correctness/noUnusedVariables  2\nrepo-two  correctness/noUnusedVariables  0')"
[[ "$plain_output" == "$expected_plain" ]] || fail "plain output did not match"
grep -F -- 'lint --only=correctness/noUnusedVariables --reporter=json --max-diagnostics=none .' "$DRY_RUN_ARGS_LOG" >/dev/null || fail "rule run did not use the required arguments"

: >"$DRY_RUN_ARGS_LOG"
markdown_output="$("$package_dir/scripts/dry-run.sh" all --markdown)"
expected_markdown="$(printf '| Repo | Rule | Count |\n| --- | --- | ---: |\n| repo-one | all | 2 |\n| repo-two | all | 0 |')"
[[ "$markdown_output" == "$expected_markdown" ]] || fail "markdown output did not match"
grep -F -- "lint --config-path=$package_dir/biome.json --vcs-enabled=true --vcs-client-kind=git --vcs-use-ignore-file=true --reporter=json --max-diagnostics=none ." "$DRY_RUN_ARGS_LOG" >/dev/null || fail "all did not use the required arguments"

printf '%s\n' "$repo_empty" >"$package_dir/.dry-run-repos"
if "$package_dir/scripts/dry-run.sh" all >"$test_dir/empty.out" 2>"$test_dir/empty.err"; then
	fail "checkout with no processed files returned success"
fi
grep -F 'Biome failed in' "$test_dir/empty.err" >/dev/null || fail "zero-file error was not printed"

printf '%s\n' "$test_dir/missing" >"$package_dir/.dry-run-repos"
if "$package_dir/scripts/dry-run.sh" all >"$test_dir/missing.out" 2>"$test_dir/missing.err"; then
	fail "missing checkout returned success"
fi
grep -F 'Missing checkout:' "$test_dir/missing.err" >/dev/null || fail "missing checkout error was not printed"

printf '%s\n' "$repo_fail" >"$package_dir/.dry-run-repos"
if "$package_dir/scripts/dry-run.sh" all >"$test_dir/fail.out" 2>"$test_dir/fail.err"; then
	fail "Biome failure returned success"
fi
grep -F 'Biome failed in' "$test_dir/fail.err" >/dev/null || fail "Biome failure error was not printed"

printf 'All dry-run tests passed.\n'
