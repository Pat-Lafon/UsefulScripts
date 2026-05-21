#!/bin/bash

# -------------- Path Configuration --------------
# Function to add directory to PATH if it exists
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}

# Add paths in order of priority (highest priority first)
pathadd "$HOME/.local/bin"
pathadd "$HOME/.cabal/bin"
pathadd "$HOME/.ghcup/bin"
pathadd "$HOME/.deno/bin"
pathadd "$HOME/.cargo/bin"
pathadd "/opt/homebrew/opt/ruby/bin"
pathadd "/opt/homebrew/opt/llvm/bin"
pathadd "/usr/local/sbin"
pathadd "$HOME/Library/Python/3.9/bin"
pathadd "/usr/textbin"
pathadd "$HOME/.elan/bin"

# -------------- Development Tool Configuration --------------
# Cargo configuration
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# GHCI configuration
export ghci="TERM=dumb ghci"

# Java configuration
if [ -x /usr/libexec/java_home ]; then
    _jh=$(/usr/libexec/java_home -v 1.8 2>/dev/null) && export JAVA_HOME="$_jh"
    unset _jh
fi

# Homebrew configuration
export HOMEBREW_NO_INSTALL_CLEANUP=1

# -------------- OS-Specific Configuration --------------
if [ "$(uname)" == "Darwin" ]; then
    # Silence bash deprecation warning on macOS
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # Clean .DS_Store files on every login as preferred
    (find "$HOME" -name ".DS_Store" -delete &>/dev/null &)
fi

# -------------- External Tool Initialization --------------
# Run env/PATH setup BEFORE sourcing .bashrc so that per-shell tool inits
# in .bashrc (starship, atuin) can find their binaries on PATH.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
    eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

if [ -r "$HOME/.opam/opam-init/init.sh" ]; then
    . "$HOME/.opam/opam-init/init.sh" >/dev/null 2>/dev/null
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Source bashrc — covers interactive-shell setup (history, aliases, functions,
# starship/atuin) for login shells too.
if [ -f "$HOME/.bashrc" ]; then
    # shellcheck source=./.bashrc
    source "$HOME/.bashrc"
fi

# List directory contents when opening a new terminal (login shells only).
# Guarded so sourcing this from a non-interactive context doesn't emit stray output.
[[ $- == *i* ]] && ls -l
