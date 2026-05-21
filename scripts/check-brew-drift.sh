#!/bin/bash
# Detect drift between brew_leaves.txt / brew_casks.txt and Homebrew's current state.
# Reports both formula and cask drift in one pass so a single CI run shows everything.
# Called by .github/workflows/brew-drift.yml; also runnable locally.
set -euo pipefail

cd "$(dirname "$0")/.."

err_prefix=""
[[ -n "${GITHUB_ACTIONS:-}" ]] && err_prefix="::error::"

# Snapshot all known formula/cask names once. Per-name `brew info` spawns Ruby
# (~1-2s each) and dominates runtime; one snapshot + in-memory lookup is ~100x faster.
# Include tap-qualified basenames so inventory short names match tapped formulae/casks
# (e.g. `cvc5` cask resolves to `cvc5/cvc5/cvc5` in `brew casks` output).
formulae_known=$(brew formulae | awk -F/ '{print; if (NF>1) print $NF}' | sort -u)
casks_known=$(brew casks       | awk -F/ '{print; if (NF>1) print $NF}' | sort -u)

drift=()

check() {
    local kind=$1 file=$2 other_inv primary_upper other_upper known other_known
    case $kind in
        formula) other_inv=brew_casks.txt;  primary_upper=FORMULA; other_upper=CASK;    known=$formulae_known; other_known=$casks_known    ;;
        cask)    other_inv=brew_leaves.txt; primary_upper=CASK;    other_upper=FORMULA; known=$casks_known;    other_known=$formulae_known ;;
    esac

    echo "=== Checking $kind drift ($file) ==="
    while IFS= read -r name || [[ -n $name ]]; do
        [[ -z $name ]] && continue
        if grep -qxF "$name" <<<"$known"; then
            continue
        fi
        if grep -qxF "$name" <<<"$other_known"; then
            drift+=("${primary_upper}→${other_upper}: $name (move from $file to $other_inv)")
        else
            drift+=("$primary_upper GONE: $name (no longer exists as formula or cask)")
        fi
    done < <(tr -d '\r' < "$file")
}

check formula brew_leaves.txt
check cask    brew_casks.txt

if (( ${#drift[@]} )); then
    for item in "${drift[@]}"; do
        printf '%s%s\n' "$err_prefix" "$item"
    done
    exit 1
fi
echo "No drift."
