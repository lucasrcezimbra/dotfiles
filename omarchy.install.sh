#!/bin/bash

set -e

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
