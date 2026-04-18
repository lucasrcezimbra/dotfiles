#!/bin/bash

set -e

sudo echo || {
	echo "Your user is is not a superuser. Run the command below and restart your computer.
su -c 'sudo usermod -aG sudo $USER'";
	exit 1;
}

backup_if_exists() {
	local path="$1"
	if [ -e "$path" ] || [ -L "$path" ]; then
		mv "$path" "$path.backup"
		echo "[install] Backed up $path"
	else
		echo "[install] Path not found, skipping backup: $path"
	fi
}

# XFCE
xfce_config_dir="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
if [ -d "$xfce_config_dir" ]; then
	backup_if_exists "$xfce_config_dir/xfce4-keyboard-shortcuts.xml"
	backup_if_exists "$xfce_config_dir/xfce4-panel.xml"
	backup_if_exists "$xfce_config_dir/xfwm4.xml"
	backup_if_exists "$xfce_config_dir/xsettings.xml"
	cp xfce4/* "$xfce_config_dir/"
	command -v pkill > /dev/null && pkill xfconfd || echo "[install] xfconfd not running, continuing"
	command -v xfce4-panel > /dev/null && xfce4-panel -r || echo "[install] xfce4-panel not available, continuing"
else
	echo "[install] XFCE config directory not found ($xfce_config_dir). Skipping XFCE setup."
fi

# Update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Essentials
sudo apt-get install -y blueman bluemon pulseaudio-module-bluetooth && sudo apt-get remove bluez-alsa-utils
sudo apt-get install -y btop
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y clang libclang-dev  # tree-sitter-cli depends on this
sudo apt-get install -y duf
sudo apt-get install -y ffmpeg
sudo apt-get install -y flameshot
sudo apt-get install -y flatpak xdg-desktop-portal xdg-desktop-portal-gtk && flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo apt-get install -y gimp
sudo apt-get install -y git
sudo apt-get install -y imagemagick
sudo apt-get install -y jq
sudo apt-get install -y libpq-dev  # library to communicate with a PostgreSQL; psycopg2 depends on this
sudo apt-get install -y nmap
sudo apt-get install -y pipx && pipx ensurepath
sudo apt-get install -y plocate && sudo updatedb
sudo apt-get install -y postgresql-client  # psql
sudo apt-get install -y pup  # jq for HTML
sudo apt-get install -y snapd
sudo apt-get install -y solaar  # Logitech manager
sudo apt-get install -y vim vim-python-jedi
sudo apt-get install -y xclip
sudo apt-get install -y zeal
sudo apt-get install -y zsh

# Firewall
sudo apt-get install -y ufw
sudo ufw enable
sudo ufw default deny incoming

# mise and tools
curl https://mise.jdx.dev/install.sh | sh
backup_if_exists ~/.config/mise/config.toml
ln -s "$PWD/mise.toml" ~/.config/mise/config.toml
touch mise.local.toml
ln -s "$PWD/mise.local.toml" ~/.config/mise/config.local.toml
mise install

# zsh
chsh -s "$(which zsh)"
# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
# .zshrc
backup_if_exists ~/.zshrc
echo ". $PWD/zshrc" >> ~/.zshrc
touch zshrc.local

# SSH
ssh-keygen -t rsa -b 4096 -C "lucas.cezimbra@gmail.com"

# NeoVim
sudo apt-get install -y luarocks
flatpak --user install -y flathub io.neovim.nvim
pipx install pynvim
## LazyVim
backup_if_exists ~/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins
ln -sd "$PWD/nvim/config/" ~/.config/nvim/lua/
ln -sd "$PWD/nvim/plugins/" ~/.config/nvim/lua/

# WezTerm
wezterm || {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg;
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list;
  sudo apt-get update;
  sudo apt-get install -y wezterm;
}
backup_if_exists ~/.wezterm.lua
ln -s "$PWD/wezterm.lua" ~/.wezterm.lua

# git
backup_if_exists ~/.gitconfig
ln -s "$PWD/gitconfig" ~/.gitconfig

# GitHub CLI
gh auth login

# git-worktree-runner (gtr)
git clone https://github.com/coderabbitai/git-worktree-runner.git ~/.local/share/git-worktree-runner
~/.local/share/git-worktree-runner/install.sh

# Flatpak
flatpak --user install -y flathub com.bitwarden.desktop
flatpak --user install -y flathub com.rafaelmardojai.Blanket
flatpak --user install -y flathub com.google.Chrome
flatpak --user install -y flathub org.mozilla.firefox
flatpak --user install -y flathub com.obsproject.Studio
flatpak --user install -y flathub com.spotify.Client
flatpak --user install -y flathub us.zoom.Zoom

# Docker
docker || {
  sudo apt-get install -y ca-certificates curl;
  sudo install -m 0755 -d /etc/apt/keyrings;
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc;
  sudo chmod a+r /etc/apt/keyrings/docker.asc;
  # shellcheck disable=all
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
  sudo apt-get update;
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;
}
sudo usermod -aG docker "$USER"

# clean
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# self config
git remote set-url origin git@github.com:lucasrcezimbra/dotfiles.git
pre-commit install

# fonts
wget -O "/tmp/jetbrains_mono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip /tmp/jetbrains_mono.zip
mkdir -p ~/.local/share/fonts/
cp /tmp/jetbrains_mono/*.ttf ~/.local/share/fonts/

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# Agents
## Agents
backup_if_exists ~/.agents
ln -s "$PWD/agents/agents" ~/.agents

## Claude
backup_if_exists ~/.claude/easyhooks
backup_if_exists ~/.claude/settings.json
ln -s "$PWD/agents/claude/easyhooks" "$PWD/agents/claude/settings.json" ~/.claude/

## Pi
backup_if_exists ~/.pi/agent/AGENTS.md
ln -s "$PWD/agents/pi/AGENTS.md" ~/.pi/agent/AGENTS.md

# Misc
backup_if_exists ~/.npmrc
ln -s "$PWD/npmrc" ~/.npmrc
backup_if_exists ~/.config/uv/uv.toml
mkdir -p ~/.config/uv/
ln -s "$PWD/uv.toml" ~/.config/uv/uv.toml

echo "Done! It's recommended to restart the system to apply all changes."
