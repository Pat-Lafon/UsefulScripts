#!/bin/bash
# For setting up my mac

# Things to be installed

# `brew leaves > brew_leaves.txt`
mapfile -t brewPackages < brew_leaves.txt
# brewPackages=(emacs python thefuck git htop docker erlang ocaml dune opam bash rebar3 gcc ccat mdcat starship hyperfine shellcheck yarn cmake clang-format wget scala open-mpi node hugo graphviz gradle gh google-java-format)

# `brew list --casks > brew_casks.txt`
mapfile -t brewCasks < brew_casks.txt
# brewCasks=(adobe-acrobat-reader battle-net discord firefox intellij-idea-ce krita mactex netnewswire omnifocus selfcontrol slack spotify steam temurin8 visual-studio-code whatsapp zoom zotero)

# `code --list-extensions > vscode_extensions.txt`
mapfile -t codeExtensions < vscode_extensions.txt

# Install brew bottles
for i in "${brewPackages[@]}"; do
    if brew ls --versions "$i" > /dev/null; then
        echo "$i" was already installed
    else
        brew install "$i"
    fi
done
brew upgrade

# Install brew casks, only available on mac
if [ "$(uname)" == "Darwin" ]; then
    for i in "${brewCasks[@]}"; do
        if brew ls --cask --versions "$i" > /dev/null; then
            echo "$i" was already installed
        else
            brew install --cask "$i"
        fi
    done
    brew cask upgrade
fi

if command -v code >/dev/null 2>&1; then
    currentExtensions="code --list-extensions"
    for i in "${codeExtensions[@]}"; do
        if $currentExtensions|grep "$i" >/dev/null 2>&1; then
            echo "$i" is already installed for VScode
        else
            code --install-extension "$i"
        fi
    done
else
    echo "VScode was not installed so we won't do extensions"
fi

if commnad -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    rustup toolchain install nightly
fi

chmod +x link.sh
./link.sh
