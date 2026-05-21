# Useful_Scripts

My collection of dotfiles, config files, and bootstrap scripts for setting up a Mac dev environment.

## Dot files

The main focus of this repository is on the config files. Files here are the source of truth; [link.sh](link.sh) symlinks them into `$HOME` (and into VS Code's and Claude Code's config locations).

* Shell: Bash -> [.bash_profile](.bash_profile) and [.bashrc](.bashrc)
* Editor: Emacs -> [.emacs](.emacs)
* IDE: VS Code -> [settings.json](settings.json)
* Version Control: Git -> [.gitconfig](.gitconfig), with aliases in [git_aliases/](git_aliases/)
* Claude Code: [claude_settings.json](claude_settings.json) (symlinked to `~/.claude/settings.json`)
* App configs: [.config/](.config/) (symlinked as a directory)

## Setup

Bootstrap a fresh machine:

```
make setup   # runs bootstrap.sh -> setup.sh: installs brew, then iterates the inventory files
make link    # symlinks dotfiles into $HOME (also run automatically by setup.sh)
make reload  # refreshes the inventory files from current state
```

The `.txt` inventory files drive what gets installed: `brew_leaves.txt`, `brew_casks.txt`, `brew_cask_taps.txt`, `vscode_extensions.txt`, `npm_globals.txt`, `cargo_installs.txt`. Edit them directly, or regenerate from machine state with `make reload`.

`cargo_installs.txt` only tracks crates.io packages — `make reload` filters out local-path and git-URL installs from `cargo install --list` since those aren't restorable on a fresh machine.
