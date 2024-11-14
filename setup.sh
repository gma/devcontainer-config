#!/bin/bash

# This script will be run automatically by the devcontainer cli, when this
# repository is specified via the --dotfiles-repository switch.
#
# Before running this script the devcontainer tools will set PWD to the repo's
# root directory.

## Functions

log()
{
    echo "## $(basename "$0"): $*"
}


clone_repo()
{
    local repo="$1"
    local target
    target="$REPOS/$(basename "$repo" .git)"
    if [ -d "$target" ]; then
        log "Skipping clone of $repo: already exists"
    else
        git clone "$repo" "$target"
    fi
}


install_ruby_tooling()
{
    log "Installing system gems"
    gem install \
        gem-browse \
        gem-ctags \
        neovim \
        ripper-tags

    local dest
    dest="$HOME/.rbenv/plugins/rbenv-ctags"
    if [ ! -d "$dest" ]; then
        log "Installing rbenv ctags plugin"
        mkdir -p ~/.rbenv/plugins
        git clone https://github.com/tpope/rbenv-ctags.git "$dest"
    fi

    if command -v ctags >/dev/null; then
        gem ctags
        rbenv ctags
        if [ -f ~/Code/dotfiles/.bashrc-ruby ]; then
            source ~/Code/dotfiles/.bashrc-ruby
            tag-bundled-gems
        fi
    fi
}


## Main program

REPOS="${1:-$HOME/Code}"

set -euo pipefail

mkdir -p "$REPOS"

clone_repo git@github.com:gma/dotfiles.git
# find "$REPOS/dotfiles" -maxdepth 1 -name \.\* -print | \
#     grep -v .gitconfig | \
#     xargs ln -sf -t ~
ln -sf "$REPOS/dotfiles/base16-theme.vscode" ~/.config/base16-theme
ln -sf "$REPOS/dotfiles/base16-theme.vscode" ~/.config/base16-theme.vscode

clone_repo git@github.com:gma/nvim-config.git
mkdir -p ~/.config && ln -sf "$REPOS/nvim-config" ~/.config/nvim

command -v rbenv >/dev/null && install_ruby_tooling
