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

# nvim
mv ~/.config/nvim/lua/config ~/.config/nvim/lua/config_backup 2>/dev/null
mv ~/.config/nvim/lua/plugins ~/.config/nvim/lua/plugins_backup 2>/dev/null
ln -sd "$PWD/nvim/config/" ~/.config/nvim/lua/
ln -sd "$PWD/nvim/plugins/" ~/.config/nvim/lua/

# hyprland
mv ~/.config/hypr/ ~/.config/hypr_backup/ 2>/dev/null
ln -s "$PWD/hypr/" ~/.config/

# Enable GTK primary selection paste with middle click, matching X11/XFCE behavior.
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true

# waybar
mv ~/.config/waybar/ ~/.config/waybar_backup/ 2>/dev/null
ln -s "$PWD/waybar/" ~/.config/

# atuin
sudo pacman -S --noconfirm --needed atuin bash-preexec
mkdir -p ~/.config/atuin
mv ~/.config/atuin/config.toml ~/.config/atuin/config.toml.backup 2>/dev/null
ln -s "$PWD/atuin.toml" ~/.config/atuin/config.toml
atuin import auto

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
omarchy-webapp-install Telegram https://web.telegram.org/ https://web.telegram.org/a/icon-192x192.png

# Bitwarden
sudo pacman -Sy --noconfirm bitwarden bitwarden-cli

# Tailscale
omarchy-install-tailscale

# Dictation (Voxtype)
yes | omarchy-voxtype-install
mkdir -p ~/.config/voxtype
mv ~/.config/voxtype/config.toml ~/.config/voxtype/config.toml.backup 2>/dev/null
ln -s "$PWD/voxtype.toml" ~/.config/voxtype/config.toml

# Chrome
omarchy-install-chromium-google-account

# Terminal
omarchy-install-terminal ghostty

# Dbeaver
sudo pacman -Sy
sudo pacman -S --noconfirm --needed dbeaver

# Agents
## ai-usagebar
yay -S --noconfirm --needed ai-usagebar-bin
mkdir -p ~/.config/ai-usagebar
mv ~/.config/ai-usagebar/config.toml ~/.config/ai-usagebar/config.toml.backup 2>/dev/null
ln -s "$PWD/ai-usagebar.toml" ~/.config/ai-usagebar/config.toml

## Agents
mv ~/.agents{,-bkp}
ln -s "$PWD/agents/agents" ~/.agents

## Pi
mv ~/.pi/agent/AGENTS.md{,-bkp}
ln -s "$PWD/agents/pi/AGENTS.md" ~/.pi/agent/AGENTS.md
tmp=$(mktemp) && jq '.prompts += ["~/.agents/commands/"]' ~/.pi/agent/settings.json > "$tmp" && mv "$tmp" ~/.pi/agent/settings.json
tmp=$(mktemp) && jq '.extensions += ["'"$PWD"'/agents/pi/extensions"]' ~/.pi/agent/settings.json > "$tmp" && mv "$tmp" ~/.pi/agent/settings.json
pi install npm:pi-mcp-adapter
pi install git:github.com/lucasrcezimbra/pi-prompt-template-model
pi install git:github.com/badlogic/pi-telegram
