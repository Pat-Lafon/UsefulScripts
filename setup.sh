#!/bin/bash
# For setting up my mac

cd "$(dirname "$0")" || exit 1

# Things to be installed

brewPackages=()
brewCasks=()
codeExtensions=()

# `brew leaves > brew_leaves.txt`
[ -f brew_leaves.txt ] && mapfile -t brewPackages < brew_leaves.txt

# `brew list --casks > brew_casks.txt`
[ -f brew_casks.txt ] && mapfile -t brewCasks < brew_casks.txt

# `code --list-extensions > vscode_extensions.txt`
[ -f vscode_extensions.txt ] && mapfile -t codeExtensions < vscode_extensions.txt

# Tap any third-party taps used by the inventory files (e.g. cvc5/cvc5 for the
# cvc5 cask) before installs.
./scripts/setup-brew-taps.sh

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
fi

if command -v code >/dev/null 2>&1; then
    mapfile -t currentExtensions < <(code --list-extensions)
    for i in "${codeExtensions[@]}"; do
        if printf '%s\n' "${currentExtensions[@]}" | grep -Fxq "$i"; then
            echo "$i" is already installed for VScode
        else
            code --install-extension "$i"
        fi
    done
else
    echo "VScode was not installed so we won't do extensions"
fi

if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    rustup toolchain install nightly
fi

# Install npm globals (`npm ls -g --depth=0 --parseable ... > npm_globals.txt`).
if command -v npm >/dev/null 2>&1 && [ -f npm_globals.txt ]; then
    mapfile -t npmGlobals < npm_globals.txt
    mapfile -t currentNpm < <(npm ls -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $NF}')
    for i in "${npmGlobals[@]}"; do
        [ -z "$i" ] && continue
        if printf '%s\n' "${currentNpm[@]}" | grep -Fxq "$i"; then
            echo "$i" is already installed for npm
        else
            npm install -g "$i"
        fi
    done
fi

# Install cargo binaries (`cargo install --list` filtered to crates.io only).
if command -v cargo >/dev/null 2>&1 && [ -f cargo_installs.txt ]; then
    mapfile -t cargoBins < cargo_installs.txt
    mapfile -t currentCargo < <(cargo install --list | grep -E '^[a-zA-Z0-9_-]+ v[0-9].*:$' | awk '{print $1}')
    for i in "${cargoBins[@]}"; do
        [ -z "$i" ] && continue
        if printf '%s\n' "${currentCargo[@]}" | grep -Fxq "$i"; then
            echo "$i" is already installed for cargo
        else
            cargo install "$i"
        fi
    done
fi

chmod +x link.sh
./link.sh
