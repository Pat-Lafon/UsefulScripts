#!/bin/bash

# -------------- History Configuration --------------
export HISTCONTROL=erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTIGNORE="ls:ll:cd:pwd:exit:clear:history"

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
pathadd "/opt/homebrew/opt/llvm@16/bin"
pathadd "$HOME/.elan/bin"

# -------------- Development Tool Configuration --------------
# Cargo configuration
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Docker for M1 configuration
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# GHCI configuration
export ghci="TERM=dumb ghci"

# Java configuration
if [ -f /usr/libexec/java_home ]; then
    JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
    export JAVA_HOME
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
# Source bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    # shellcheck source=./.bashrc
    source "$HOME/.bashrc"
fi

if [ -r "$HOME/.opam/opam-init/init.sh" ]; then
    . "$HOME/.opam/opam-init/init.sh" >/dev/null 2>/dev/null
fi

# Initialize shell enhancements
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -x "$(command -v starship)" ] && eval "$(starship init bash)"
[ -x "$(command -v atuin)" ] && eval "$(atuin init bash)"

# Only load bash-preexec if not in a VS Code terminal or Copilot agent context
if [[ -z "$VSCODE_INJECTION" && -z "$TERM_PROGRAM" ]] || [[ "$TERM_PROGRAM" != "vscode" ]]; then
    [ -f "$HOMEBREW_PREFIX"/etc/profile.d/bash-preexec.sh ] && . "$HOMEBREW_PREFIX"/etc/profile.d/bash-preexec.sh
fi

# Source cargo environment if it exists
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# List directory contents when opening a new terminal (personal preference)
ls -l
