#!/bin/bash

# Set up symlinks
if command -v code >/dev/null 2>&1; then
    CodeSettings=$PWD/settings.json
    ln -sf "$CodeSettings" ~/Library/Application\ Support/Code/User
    echo Created VScode settings link
else
    echo "VScode is not installed so we won't link settings"
fi

BashSettings=$PWD/.bashrc
ln -sf "$BashSettings" ~
echo Created Bash settings link

ProfileSettings=$PWD/.bash_profile
ln -sf "$ProfileSettings" ~
echo Created Bash_Profile settings link

GitSettings=$PWD/.gitconfig
ln -sf "$GitSettings" ~
echo Created Git settings link

EmacsSettings=$PWD/.emacs
ln -sf "$EmacsSettings" ~
echo Created Emacs settings link