#!/bin/bash

export PATH=${PATH}:/usr/textbin
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export HISTCONTROL=erasedups

if [ -f /usr/libexec/java_hom ]; then
    export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
fi

if [ "$(uname)" == "Darwin" ]; then
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi

printf '\033[8;25;100t'

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

ls -l

if [ "$(uname)" == "Darwin" ]; then
    (find ~ -name ".DS_Store" -delete &>/dev/null &)
fi

# opam configuration
test -r /Users/patricklafontaine/.opam/opam-init/init.sh && . /Users/patricklafontaine/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
