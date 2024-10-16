#!/bin/bash

# This script will be run automatically by the devcontainer cli, when this
# repository is specified via the --dotfiles-repository switch.
#
# Before running this script the devcontainer tools will set PWD to the repo's
# root directory.

## Functions

clone_repo()
{
    local repo="$1"
    git clone "$repo" "$REPOS/$(basename "$repo" .git)"
}


## Main program

REPOS="${1:-$HOME/Code}"

set -euo pipefail

mkdir -p "$REPOS"

clone_repo git@github.com:gma/dotfiles.git
find "$REPOS/dotfiles" -maxdepth 1 -name \.\* -print | \
    grep -v .gitconfig | \
    xargs ln -sf -t ~
ln -sf "$REPOS/dotfiles/base16-theme.vscode" ~/.config/base16-theme
ln -sf "$REPOS/dotfiles/base16-theme.vscode" ~/.config/base16-theme.vscode

clone_repo git@github.com:gma/nvim-config.git
mkdir -p ~/.config && ln -sf "$REPOS/nvim-config" ~/.config/nvim
