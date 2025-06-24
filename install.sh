#!/bin/bash

set -e

sudo echo || {
	echo "Your user is is not a superuser. Run the command below and restart your computer.
su -c 'sudo usermod -aG sudo $USER'";
	exit 1;
}

# XFCE
mv ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml{,.backup}
mv ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml{,.backup}
mv ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml{,.backup}
mv ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml{,.backup}
cp xfce4/* ~/.config/xfce4/xfconf/xfce-perchannel-xml/
pkill xfconfd
xfce4-panel -r

# Update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Essentials
sudo apt-get install -y blueman bluemon pulseaudio-module-bluetooth && sudo apt-get remove bluez-alsa-utils
sudo apt-get install -y btop
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y duf
sudo apt-get install -y ffmpeg
sudo apt-get install -y flameshot
sudo apt-get install -y flatpak && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo apt-get install -y gimp
sudo apt-get install -y hugo
sudo apt-get install -y imagemagick
sudo apt-get install -y jq
sudo apt-get install -y libpq-dev  # library to communicate with a PostgreSQL; psycopg2 depends on this
sudo apt-get install -y git
sudo apt-get install -y pipx && pipx ensurepath
sudo apt-get install -y plocate && sudo updatedb
sudo apt-get install -y snapd
sudo apt-get install -y solaar  # Logitech manager
sudo apt-get install -y vim vim-python-jedi
sudo apt-get install -y xclip
sudo apt-get install -y zeal
sudo apt-get install -y zsh

# Firewall
sudo apt-get install -y ufw
sudo ufw default deny incoming

# zsh
chsh -s "$(which zsh)"
# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

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

# SSH
ssh-keygen -t rsa -b 4096 -C "lucas.cezimbra@gmail.com"

# .zshrc
mv ~/.zshrc ~/.zshrc_backup 2> /dev/null
echo ". $PWD/zshrc" >> ~/.zshrc
touch zshrc.local

# Rust and tools
curl https://sh.rustup.rs -sSf | sh
cargo install ast-grep --locked
cargo install eza --locked
cargo install fd-find
cargo install ripgrep
cargo install starship --locked
cargo install zoxide --locked

# NeoVim
sudo apt-get install -y luarocks
flatpak install flathub io.neovim.nvim
pipx install pynvim
pyenv virtualenv debugpy && pyenv shell debugpy && pip install debugpy && pyenv shell --unset
## LazyVim
mv ~/.config/nvim{,.bak}
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins
ln -sd "$PWD/nvim/config/" ~/.config/nvim/lua/
ln -sd "$PWD/nvim/plugins/" ~/.config/nvim/lua/

# mise and tools
curl https://mise.jdx.dev/install.sh | sh
mise use -g node@lts
mise use -g python

# WezTerm
wezterm || {
  curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg;
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list;
  sudo apt-get update;
  sudo apt-get install -y wezterm;
}
mv ~/.wezterm.lua ~/.wezterm_backup.lua 2> /dev/null
ln -s "$PWD/wezterm.lua" ~/.wezterm.lua

# llm
pipx install llm
llm install llm-cmd
mv ~/.config/io.datasette.llm/templates ~/.config/io.datasette.llm/templates-backup || mkdir -p ~/.config/io.datasette.llm/templates
ln -s "$PWD/llm-templates" ~/.config/io.datasette.llm/templates

# git
cargo install git-delta
cargo install mergiraf
cargo install difftastic
mv ~/.gitconfig ~/.gitconfig_backup 2> /dev/null
ln -s "$PWD/gitconfig" ~/.gitconfig

# GitHub CLI
gh || {
  # shellcheck disable=all
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
          && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y;
}
gh auth login

# Flatpak
flatpak install -y flathub com.bitwarden.desktop
flatpak install -y flathub com.google.Chrome
flatpak install -y flathub org.mozilla.firefox
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub us.zoom.Zoom

# pre-commit
pipx install pre-commit

# poetry
pipx install poetry

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

echo "Done! It's recommended to restart the system to apply all changes."
