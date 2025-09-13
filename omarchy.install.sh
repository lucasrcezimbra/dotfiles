#!/bin/bash

set -e

# git
mv ~/.gitconfig ~/.gitconfig_backup 2>/dev/null
ln -s "$PWD/gitconfig" ~/.gitconfig

# hyprland
mv ~/.config/hypr/ ~/.config/hypr_backup/ 2>/dev/null
ln -s "$PWD/hypr/" ~/.config/
