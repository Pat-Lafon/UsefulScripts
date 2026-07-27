#!/bin/sh
# git up [<remote>] <branch> -- fetch, then rebase onto <remote>/<branch>.
set -u

die() {
  echo "git up: $*" >&2
  exit 1
}

# Echo the one remote carrying <branch>, or die naming the choices.
# Callers fetch first; this reads remote-tracking refs as authoritative.
deduce_remote() {
  branch=$1

  set --
  for ref in $(git for-each-ref --format='%(refname:lstrip=2)' "refs/remotes/*/$branch"); do
    set -- "$@" "${ref%"/$branch"}"
  done

  case $# in
    0) die "no remote has '$branch'" ;;
    1) echo "$1"; return ;;
  esac

  # Multi-remote tie-break; unset means we can't guess, so we ask.
  preferred=$(git config --get checkout.defaultRemote)
  for r in "$@"; do
    if [ "$r" = "$preferred" ]; then
      echo "$r"
      return
    fi
  done
  die "'$branch' is on several remotes, name one: $*"
}

case $# in
  1)
    branch=$1
    git fetch --all --prune || exit 1
    remote=$(deduce_remote "$branch") || exit 1
    echo "git up: using remote '$remote'" >&2
    ;;
  2)
    remote=$1
    branch=$2
    git fetch "$remote" "$branch" || exit 1
    ;;
  *) die "usage: git up [<remote>] <branch>" ;;
esac

git rebase "$remote/$branch"
