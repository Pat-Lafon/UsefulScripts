#!/bin/bash

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
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    fi
    if [[ -d ~/.linuxbrew ]]; then
        eval "$(/home/pwl45/.linuxbrew/bin/brew shellenv)"
    fi
fi

bash setup.sh