#!/bin/bash

# Convention: every repo file linked into $HOME is referenced as
# "$PWD/<path>" on the source side of an `ln` call. .github/workflows/ci.yml
# greps for that exact `$PWD/...` pattern to verify each source exists in
# the repo, so don't rewrite these as bare paths or relative refs.

# Set up symlinks
if command -v code >/dev/null 2>&1; then
    CodeSettings=$PWD/settings.json
    CodeSnippets=$PWD/.vscode/snippets
    ln -sf "$CodeSettings" "$HOME/Library/Application Support/Code/User/settings.json"
    ln -sfn "$CodeSnippets" "$HOME/Library/Application Support/Code/User/snippets"
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

ConfigSettings=$PWD/.config
# -n is critical: without it, ln follows an existing ~/.config symlink and
# creates ~/.config/.config (nesting). With -fn, the existing symlink is
# unlinked and replaced.
ln -sfn "$ConfigSettings" ~/.config
echo Created general config directory link

SshRc=$PWD/ssh_rc
mkdir -p ~/.ssh
ln -sf "$SshRc" ~/.ssh/rc
echo Created ssh rc link