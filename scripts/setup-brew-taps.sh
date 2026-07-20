#!/bin/bash
# Tap every brew tap referenced by the inventory files.
# Called by setup.sh (new-machine bootstrap) and .github/workflows/brew-drift.yml.
set -euo pipefail

cd "$(dirname "$0")/.."

# In GitHub Actions, prefix errors so they surface in the run UI.
err_prefix=""
[[ -n "${GITHUB_ACTIONS:-}" ]] && err_prefix="::error::"

for f in brew_leaves.txt brew_cask_taps.txt; do
    if [[ ! -f "$f" ]]; then
        printf '%sinventory file missing: %s\n' "$err_prefix" "$f" >&2
        exit 1
    fi
done

fail=()
existing_taps=$(brew tap)

# Sources:
#   - tap-qualified leaves in brew_leaves.txt (e.g. foo/bar/baz -> foo/bar)
#   - brew_cask_taps.txt (cask short names don't reveal their tap, so it's listed explicitly)
# Skip `#` comments and blank lines, merge, dedupe so shared taps only tap once.
# Trust every tap unconditionally: with $HOMEBREW_REQUIRE_TAP_TRUST set (the CI
# runner default), an untapped-but-trusted tap is still skipped by `brew casks`/
# `brew formulae`, and trust is independent of whether the tap already exists.
while IFS= read -r tap; do
    if ! grep -qxFi "$tap" <<<"$existing_taps"; then
        echo "tapping $tap"
        brew tap "$tap" || { fail+=("$tap"); continue; }
    fi
    brew trust --tap "$tap" || fail+=("$tap")
done < <(
    {
        awk -F/ '!/^[[:space:]]*#/ && NF>=3 {print $1"/"$2}' brew_leaves.txt
        awk '!/^[[:space:]]*#/ && NF' brew_cask_taps.txt
    } | sort -u
)

if (( ${#fail[@]} )); then
    for t in "${fail[@]}"; do
        printf '%stap failed: %s\n' "$err_prefix" "$t" >&2
    done
    exit 1
fi
