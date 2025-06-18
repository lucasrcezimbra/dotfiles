sudo echo || {
	echo "Your user is is not a superuser. Run the command below and restart your computer.
su -c 'sudo usermod -aG sudo $USER'";
	exit 1;
}

# XFCE
mv ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml.backup
ln -s ~/.dotfiles/xfce4/xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
xfconf-query --channel xfce4-panel --property '/plugins/plugin-1/button-title' --set ''
xfconf-query --channel xfce4-panel --property '/plugins/plugin-2/grouping' --set '0'

# Update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Essentials
sudo apt-get install -y blueman bluez-* pulseaudio-module-bluetooth bluemon  # bluetooth
sudo apt-get install -y btop
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y duf
sudo apt-get install -y git
sudo apt-get install -y pipx && pipx ensurepath
sudo apt-get install -y snapd
sudo apt-get install -y vim vim-python-jedi
sudo apt-get install -y zeal
sudo apt-get install -y zsh

# Firewall
sudo apt-get install ufw
sudo ufw default deny incoming

# pyenv
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

# zsh
chsh -s $(which zsh)
# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Docker
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# SSH
ssh-keygen -t rsa -b 4096 -C "lucas.cezimbra@gmail.com"

# .zshrc
mv ~/.zshrc ~/.zshrc_backup 2> /dev/null
echo ". $PWD/zshrc" >> ~/.zshrc
touch zshrc.local

# Rust
curl https://sh.rustup.rs -sSf | sh

# NeoVim
sudo snap install --classic nvim
pipx install pynvim
pyenv virtualenv debugpy && pyenv shell debugpy && pip install debugpy && pyenv shell --unset
## LazyVim
mv ~/.config/nvim{,.bak}
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins
ln -sd "$PWD/nvim/config/" ~/.config/nvim/lua/
ln -sd "$PWD/nvim/plugins/" ~/.config/nvim/lua/

# mise
curl https://mise.jdx.dev/install.sh | sh

# startship
cargo install starship --locked

# eza
cargo install eza

# WezTerm
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt-get update
sudo apt-get install wezterm
mv ~/.wezterm.lua ~/.wezterm_backup.lua 2> /dev/null
ln -s $PWD/wezterm.lua ~/.wezterm.lua

# llm
pipx install llm
mv ~/.config/io.datasette.llm/templates ~/.config/io.datasette.llm/templates-backup || mkdir -p ~/.config/io.datasette.llm/templates
ln -s $PWD/llm-templates ~/.config/io.datasette.llm/templates

# plocate
sudo apt-get install plocate
sudo updatedb

# git
cargo install git-delta
cargo install mergiraf
cargo install difftastic
mv ~/.gitconfig ~/.gitconfig_backup 2> /dev/null
ln -s $PWD/gitconfig ~/.gitconfig

# clean
sudo apt-get autoremove -y
sudo apt-get autoclean -y
