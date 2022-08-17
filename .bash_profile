#!/bin/bash

export PATH="$PATH:/usr/textbin"

export PATH="$PATH:~/Library/Python/3.9/bin"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export HISTCONTROL=erasedups

## THIS IS FOR GHCI, the interpreter of Haskell
export ghci="TERM=dumb ghci"

if [ -f /usr/libexec/java_home ]; then
    JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
    export JAVA_HOME
fi

if [ "$(uname)" == "Darwin" ]; then
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi

printf '\033[8;25;100t'

if [ -f ~/.bashrc ]; then
    # shellcheck source=./.bashrc
    source ~/.bashrc
fi

ls -l

if [ "$(uname)" == "Darwin" ]; then
    (find ~ -name ".DS_Store" -delete &>/dev/null &)
fi

# opam configuration
test -r /Users/patricklafontaine/.opam/opam-init/init.sh && . /Users/patricklafontaine/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
export PATH="/usr/local/opt/llvm/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
eval "$(/opt/homebrew/bin/brew shellenv)"
. "$HOME/.cargo/env"

export PATH="$HOME/.elan/bin:$PATH"
export PATH="/opt/homebrew/opt/ghc@9/bin:$PATH"
