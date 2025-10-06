#!/bin/bash

set -e

# shell configs
echo "source $PWD/zshrc" >>~/.zshrc
echo "source $PWD/bashrc" >>~/.bashrc

# mise tools
mv ~/.config/mise/config.toml{,.backup}
ln -s "$PWD/mise.toml" ~/.config/mise/config.toml
touch mise.local.toml
ln -s "$PWD/mise.local.toml" ~/.config/mise/config.local.toml
mise install

# git
mv ~/.gitconfig ~/.gitconfig_backup 2>/dev/null
ln -s "$PWD/gitconfig" ~/.gitconfig

# hyprland
mv ~/.config/hypr/ ~/.config/hypr_backup/ 2>/dev/null
ln -s "$PWD/hypr/" ~/.config/

# GitHub CLI
gh auth login

# self config
git remote set-url origin git@github.com:lucasrcezimbra/dotfiles.git
# TODO: remove XFCE stuff from pre-commit
# pre-commit install

# remove unused stuff
omarchy-webapp-remove Basecamp Figma 'Google Contacts' 'Google Messages' 'Google Photos' HEY Zoom
sudo pacman -Rns --noconfirm 1password-cli 1password-beta signal-desktop typora
# TODO decide
# sudo pacman -Rns --noconfirm lazydocker lazygit localsend-bin obsidian

# Bitwarden
sudo pacman -Sy --noconfirm bitwarden bitwarden-cli

# Tailscale
omarchy-install-tailscale

# Claude
mv ~/.claude/agents{,-bkp}
mv ~/.claude/hooks{,-bkp}
mv ~/.claude/settings.json{,.bkp}
ln -s "$PWD/claude/agents" "$PWD/claude/easyhooks" "$PWD/claude/hooks" "$PWD/claude/settings.json" ~/.claude/
