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

# web apps
omarchy-webapp-install Todoist https://app.todoist.com/app/ https://app.todoist.com/favicon.ico

# Bitwarden
sudo pacman -Sy --noconfirm bitwarden bitwarden-cli

# Tailscale
omarchy-install-tailscale

# Dictation (Voxtype)
yes | omarchy-voxtype-install

# Chrome
omarchy-install-chromium-google-account

# Terminal
omarchy-install-terminal ghostty

# Dbeaver
sudo pacman -Sy
sudo pacman -S --noconfirm --needed dbeaver

# Agents
## Agents
mv ~/.agents{,-bkp}
ln -s "$PWD/agents/agents" ~/.agents

## Pi
mv ~/.pi/agent/AGENTS.md{,-bkp}
ln -s "$PWD/agents/pi/AGENTS.md" ~/.pi/agent/AGENTS.md
tmp=$(mktemp) && jq '.prompts += ["~/.agents/commands/"]' ~/.pi/agent/settings.json > "$tmp" && mv "$tmp" ~/.pi/agent/settings.json
tmp=$(mktemp) && jq '.extensions += ["'"$PWD"'/agents/pi/extensions"]' ~/.pi/agent/settings.json > "$tmp" && mv "$tmp" ~/.pi/agent/settings.json
