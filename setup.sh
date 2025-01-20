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


persist_bundle_path_for_vim_bundler()
{
    # The vim-bundler Vim plugin doesn't support reading the BUNDLE_PATH
    # environment variable (which is typically set via the bundler-cache
    # devcontainer feature, that can be included in devcontainer.json, for
    # Rails projects), so we'll have to write it to a config file for it.
    # Otherwise, we won't be able to use vim-bundler to navigate the source in
    # gems that have been installed in the bundle, despite us having gone to
    # the trouble of create tags files by installing gem-ctags!
    local config
    config=".bundle/config"
    if [ -n "$BUNDLE_PATH" ] && [ -f "$config" ]; then
        mkdir -p "$(dirname "$config")"
    cat <<EOF > "$config"
---
BUNDLE_PATH: "$BUNDLE_PATH"
EOF
    else
        echo "WARNING: Not saving BUNDLE_PATH - vim-bundler could struggle" 1>&2
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
        mkdir -p "$(dirname "$dest")"
        git clone https://github.com/tpope/rbenv-ctags.git "$dest"
    fi

    if command -v ctags >/dev/null; then
        gem ctags
        rbenv ctags
        if [ -f ~/Code/dotfiles/.bashrc-ruby ]; then
            source ~/Code/dotfiles/.bashrc-ruby
            tag-bundled-gems || true
        fi
    fi

    persist_bundle_path_for_vim_bundler
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
log "Installing Neovim plugins with Lazy"
nvim --headless "+Lazy! restore" +qa >/dev/null

log "Fixing up Neovim colours"
cat <<EOF >> ~/.bashrc

export EDITOR=nvim
export TERM=screen-256color
EOF

command -v rbenv >/dev/null && install_ruby_tooling
