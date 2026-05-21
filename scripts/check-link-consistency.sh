#!/bin/bash
# Verify every link source referenced in link.sh exists in the repo.
# Greps for the `$PWD/<path>` convention link.sh uses for source assignments.
set -euo pipefail

cd "$(dirname "$0")/.."

missing=()
# shellcheck disable=SC2016  # the literal '$PWD/' is what we're matching in link.sh
while IFS= read -r path || [[ -n $path ]]; do
    [[ -e "$path" ]] || missing+=("$path")
done < <(grep -vE '^[[:space:]]*#' link.sh | grep -oE '\$PWD/[A-Za-z0-9_./-]+' | sed 's|^\$PWD/||' | sort -u)

if (( ${#missing[@]} )); then
    printf 'MISSING (referenced in link.sh but not present in repo): %s\n' "${missing[@]}"
    exit 1
fi
