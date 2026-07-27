# UsefulScripts — dotfiles and machine bootstrap

## Repository purpose

This repo serves two intertwined roles for the user:

1. **New-machine bootstrap** — a starting point for setting up a fresh development environment (install Homebrew, restore brew packages/casks, VS Code extensions, dotfiles, symlinks).
2. **Working collection of utilities and config files** — the dotfiles, shell helpers, git aliases, editor/IDE settings, and tool configs the user actually relies on day-to-day across the various kinds of development they do.

Files in this directory are the *source of truth*; `link.sh` symlinks them into `$HOME` (and into `~/Library/Application Support/Code/User` for VS Code). Editing a file here changes the live config on the user's machine via the symlink.

Claude Code's global settings are *not* here — they live in the `claude-automations` repo (`dotclaude/settings.json`), which owns the `~/.claude/` symlinks.

## Common commands

- `make setup` — runs `bootstrap.sh` → `setup.sh`, which installs Homebrew (if missing) then iterates the package lists. Idempotent: skips anything already installed.
- `make reload` — refreshes the inventory files (`brew_leaves.txt`, `brew_casks.txt`, `vscode_extensions.txt`) from the current machine state. Run this after installing new packages you want tracked.
- `./link.sh` — re-creates the symlinks from this repo into `$HOME`. Safe to re-run (`ln -sf`).

There is no test suite, linter, or build step — this is config + shell, not application code.

## Architecture

Three layers, all driven by plain bash:

1. **Inventory files** (`brew_leaves.txt`, `brew_casks.txt`, `brew_cask_taps.txt`, `vscode_extensions.txt`, `npm_globals.txt`, `cargo_installs.txt`) — package lists, refreshed by `make reload`. Edit by adding/removing entries directly, or regenerate from machine state. Two filtering caveats:
   - `npm_globals.txt`: `npm` itself is excluded so a fresh-machine install doesn't try to `npm install -g npm`.
   - `cargo_installs.txt`: only crates.io packages are kept. `cargo install --list` also shows local-path installs (e.g. dev installs from `~/Desktop/Github/<repo>`) and git-URL installs; both are stripped by `make reload` since they don't restore on a fresh machine. If you genuinely want a git install reproduced, add it to a separate script or install it by hand. `make reload` also strips a hardcoded list of rustup-managed components (`miri`, `rust-analyzer`, `rustfmt`, `clippy`) — they appear in `cargo install --list` as stub crates but `cargo install` won't restore them correctly; they belong to `rustup component add`.
2. **Installers** (`bootstrap.sh`, `setup.sh`) — read the inventory files and install anything missing. `bootstrap.sh` handles prerequisites (shell, xcode-select, brew); `setup.sh` does the iteration.
3. **Linker** (`link.sh`) — symlinks every dotfile/config from this repo into the appropriate location in `$HOME`. This is what makes "editing a file here" equivalent to "editing the live config."

Dotfiles themselves (`.bashrc`, `.bash_profile`, `.emacs`, `.gitconfig`, VS Code `settings.json`, `.config/`) are independent and meant to be edited in place.

## `.bash_profile` vs `.bashrc` split

The two files have distinct, non-overlapping responsibilities. Keep edits on the correct side:

- **`.bash_profile` — login-shell setup that should run once per session.** PATH construction (via the `pathadd` helper), env vars (`CARGO_*`, `JAVA_HOME`, `HOMEBREW_NO_INSTALL_CLEANUP`, `BASH_SILENCE_DEPRECATION_WARNING`), tool env injection (`brew shellenv`, `opam`, `cargo env`), OS-specific login chores (the macOS `.DS_Store` sweep), and login-only side effects like the guarded `ls -l` at the very end.
- **`.bashrc` — interactive, per-shell setup.** Starts with `[[ $- == *i* ]] || return` so non-interactive shells bail immediately. Holds history config, aliases, the function overrides below, and per-shell tool hooks that touch `PROMPT_COMMAND`/keybindings/`PS1` (`starship init bash`, `atuin init bash`).

`.bash_profile` sources `.bashrc` at the end, **after** PATH and tool env are set up — that's deliberate, so `starship`/`atuin` are findable on `PATH` when `.bashrc` tries to init them. Don't move the `source ~/.bashrc` earlier in `.bash_profile`, and don't put prompt/history hooks in `.bash_profile` (they wouldn't fire in non-login interactive shells like a new tmux pane).

Rule of thumb when adding something new: *runs in every interactive shell* (prompt, completion, aliases) → `.bashrc`. *Sets state inherited by child processes* (PATH, env vars) → `.bash_profile`.

## Shell function overrides (.bashrc)

`.bashrc` wraps several common commands with `function name() { ... command name "$@"; }`. These are intentional and have user-meaningful behavior — be careful not to break them:

- `git push --force` is silently rewritten to `--force-with-lease`.
- `brew rm`/`uninstall` auto-removes orphaned dependencies afterward.
- `gh repo clone` auto-`cd`s into the cloned dir and sets the default repo.
- `cat` is piped through `bat --style=plain --paging=never`, falling back to real `cat` if `bat` isn't installed.
- `ls` with any `l` in the args gets `-GhLa` added.
- `rm -r*` adds `-f`, prompts before deleting any target that has uncommitted git changes, and runs `ls -l` afterward.

When suggesting shell changes, assume the user is running these wrappers — e.g. `git push --force` from their shell is actually `--force-with-lease`.

## Working with `todo.md`

When you notice a tangential issue while working on a task — a related bug, stale config, duplicate, or other cleanup that isn't part of the current request — **add it to `todo.md`** under the appropriate priority section instead of either silently fixing it or only mentioning it in chat. Examples of what triggers a new entry: a sibling of the bug you're fixing (e.g. a duplicate package name spotted while fixing an unrelated entry), a stale path or version pin observed in passing, a dead-code branch noticed while reading nearby code. Chat mentions get lost; todo entries persist.

## Notes for editing config files

- `.config/` is symlinked as a directory, so subdirs ignored via `.gitignore` (`.config/gcloud`, `.config/iterm2`, `.config/dnd-lore-review`) live on disk but aren't tracked here.
- `.gitconfig` aliases resolve `git_aliases/*.sh` at runtime via `readlink ~/.gitconfig`, so the repo can live anywhere as long as `.gitconfig` is symlinked from it (which `link.sh` does).
