#!/bin/bash

export PATH="$PATH:/usr/textbin"

export PATH="$PATH:~/Library/Python/3.9/bin"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export HISTCONTROL=erasedups
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
export HOMEBREW_NO_INSTALL_CLEANUP=

## Docker for m1 stuff
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
export DOCKER_DEFAULT_PLATFORM=linux/amd64

## THIS IS FOR GHCI, the interpreter of Haskell
export ghci="TERM=dumb ghci"

if [ -f /usr/libexec/java_home ]; then
    JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
    export JAVA_HOME
fi

if [ "$(uname)" == "Darwin" ]; then
    export BASH_SILENCE_DEPRECATION_WARNING=
fi

if [ -f ~/.bashrc ]; then
    # shellcheck source=./.bashrc
    source ~/.bashrc
fi

ls -l

if [ "$(uname)" == "Darwin" ]; then
    (find ~ -name ".DS_Store" -delete &>/dev/null &)
fi

# opam configuration
test -r /Users/patricklafontaine/.opam/opam-init/init.sh && . /Users/patricklafontaine/.opam/opam-init/init.sh >/dev/null 2>/dev/null || true

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
eval "$(/opt/homebrew/bin/brew shellenv)"


export PATH="/Users/patricklafontaine/.deno/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

eval "$(starship init bash)"
. "$HOME/.cargo/env"
export PATH="/opt/homebrew/opt/llvm@16/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"