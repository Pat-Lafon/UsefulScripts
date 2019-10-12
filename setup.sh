#!/bin/bash

# For setting up my mac

# Things to be installed
brewPackages=(emacs python thefuck git htop)
brewCasks=(visual-studio-code)

# Doing installation
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


for i in "${brewPackages[@]}"; do
    if brew ls --versions $i > /dev/null; then
        brew upgrade $i
    else
        brew install $i
    fi
done

for i in "${brewCasks[@]}"; do
    if brew cask ls --versions $i > /dev/null; then
        true
    else
        brew cask install $i
    fi
done
brew cask upgrade


CodeSettings=$PWD/settings.json
ln -sf $CodeSettings ~/Library/Application\ Support/Code/User

BashSettings=$PWD/.bashrc
ln -sf $BashSettings ~