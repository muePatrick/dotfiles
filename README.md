## Clone Repo

1. Clone repo to *~/dotfiles*: `git clone https://github.com/muePatrick/dotfiles ~/dotfiles`

## ZSH

1. [Install zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
2. [Install oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh#basic-installation)
3. [Install p10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh)
4. [Install zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh)
5. [Install zsh-fzf-history-search](https://github.com/joshskidmore/zsh-fzf-history-search#oh-my-zsh)
6. Link config file: `ln -s ./dotfiles/.zshrc .zshrc`
7. Link p10k theme: `ln -s ./dotfiles/.p10k.zsh .p10k.zsh`

## TMUX

1. [Install Tmux](https://github.com/tmux/tmux/wiki/Installing)
2. [Install TPM](https://github.com/tmux-plugins/tpm#installation)
3. Link config file: `ln -s ./dotfiles/.tmux.conf .tmux.conf`

## GIT

1. Install Git
2. [Install delta](https://github.com/dandavison/delta)
3. Link config file: `ln -s ./dotfiles/.gitconfig .gitconfig`

## NeoVim

1. Install NeoVim:
    1. Download [AppImage](https://github.com/neovim/neovim/wiki/Installing-Neovim#appimage-universal-linux-package) to *Home*, the *.zshrc* has an alias for that
2. Enable custom config from [muePatrick/kickstart.nvim](https://github.com/muePatrick/kickstart.nvim#Installation)

## VSCode

1. Install [VSCode](https://code.visualstudio.com/)
2. Start VSCode and open this folder
3. Install the plugins through the popup that will recommend all the plugins in this repo

## Fonts

1. Download and Install [Jet Brains Mono](https://github.com/JetBrains/JetBrainsMono)
    1. Setup `JetBrains Mono NL` for Terminal
2. Download and Install the two [NerfFontsSymbols Only Fonts](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/NerdFontsSymbolsOnly)
    1. They get automatically used when installed (by some of the NeoVim Plugins)
