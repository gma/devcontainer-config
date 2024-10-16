Devcontainer Config
===================

When you launch a devcontainer using the [devcontainer CLI] it can install your
dotfiles by retrieving a Git repository and running and install script.

Pass the URL of the repository to the `up` command, like this:

    devcontainer up --workspace-folder . \
        --dotfiles-repository https://github.com/gma/devcontainer-config

My dotfiles are stored in multiple repositories; one for my shell and general
utilities, and another for Neovim.

I will also need Neovim to be installed within the container. This could be
handled by a feature in `devcontainer.json`, but it's better not to install
that by default when working in a team where we don't all run Neovim.

So I typically add a devcontainer "feature" that will install Neovim from
source, and install my configuration by retrieving this repository.

    devcontainer up --workspace-folder . \
        --additional-features \
        '{ "ghcr.io/duduribeiro/devcontainer-features/neovim:1": {} }' \
        --dotfiles-repository git@github.com:gma/devcontainer-config.git \
        --dotfiles-target-path ~/devcontainer-config

[devcontainer CLI]: https://github.com/devcontainers/cli
