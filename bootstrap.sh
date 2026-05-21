#!/bin/bash

cd "$(dirname "$0")" || exit 1

# Check if bash is the main shell
if [[ $SHELL == /bin/bash ]]; then
    echo "$SHELL"
else
    chsh -s /bin/bash
fi

# Check if xcode is installed on mac
if [ "$(uname)" == "Darwin" ]; then
    if command -v xcode-select >/dev/null 2>&1; then
        echo "xcode-select already installed"
    else
        echo "xcode-select not found"
        xcode-select --install
    fi
fi

# Check homebrew installer is available
if command -v brew >/dev/null 2>&1; then
    echo "brew already installed"
else
    echo "brew not found"
    if [ "$(uname)" == "Darwin" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    fi
    if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
        eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi
fi

bash setup.sh