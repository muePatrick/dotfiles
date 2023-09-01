## Clone Repo

1. Clone repo to *~/dotfiles*: `git clone https://github.com/muePatrick/dotfiles ~/dotfiles`

## ZSH

1. [Install zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
2. [Install oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh#basic-installation)
3. Link config file: `ln -s ./dotfiles/.zshrc .zshrc`

## TMUX

1. [Install Tmux](https://github.com/tmux/tmux/wiki/Installing)
2. [Install TPM](https://github.com/tmux-plugins/tpm#installation)
3. Link config file: `ln -s ./dotfiles/.tmux.conf .tmux.conf`

## GIT

1. Install Git
2. Link config file: `ln -s ./dotfiles/.gitconfig .gitconfig`

## NeoVim

1. Install NeoVim:
  1. Download [AppImage](https://github.com/neovim/neovim/wiki/Installing-Neovim#appimage-universal-linux-package) to *Home*, the *.zshrc* has an alias for that.
2. Enable custom config from [muePatrick/kickstart.nvim](https://github.com/muePatrick/kickstart.nvim#Installation)
