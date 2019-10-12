#!/bin/bash

# For setting up my mac
if command -v xcode-select >/dev/null 2>&1 ; then
    echo "xcode-select already installed"
else
    echo "xcode-select not found"
    xcode-select --install
fi

if command -v brew >/dev/null 2>&1 ; then
    echo "brew already installed"
else
    echo "brew not found"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if command -v emacs >/dev/null 2>&1 ; then
    echo "emacs already installed"
else
    echo "emacs not found"
    brew install emacs
fi

if command -v code >/dev/null 2>&1 ; then
    echo "code already installed"
else
    echo "code not found"
    brew cask install visual-studio-code
fi

CodeSettings=$PWD/settings.json
echo $CodeSettings
ln -sf $CodeSettings ~/Library/Application\ Support/Code/User