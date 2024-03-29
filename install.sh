# XFCE
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>d' --set 'thunar Downloads' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>f' --set 'thunar' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>m' --set 'thunar Pictures/memes/' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>r' --set 'xfce4-appfinder' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>s' --set 'mousepad Desktop/strings' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>t' --set 'flatpak run org.wezfurlong.wezterm' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/Print' --set 'xfce4-screenshooter --fullscreen' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Shift>Print' --set 'xfce4-screenshooter --region' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/xfwm4/custom/<Primary><Shift><Alt>Left' --set 'move_window_left_workspace_key'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/xfwm4/custom/<Primary><Shift><Alt>Right' --set 'move_window_right_workspace_key'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/xfwm4/custom/<Primary><Super>Up' --set 'maximize_window_key' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/xfwm4/custom/<Primary><Super>Left' --set 'tile_left_key' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/xfwm4/custom/<Primary><Super>Right' --set 'tile_right_key' --create --type 'string'
xfconf-query --channel xfce4-panel --property '/plugins/plugin-1/button-title' --set ''
xfconf-query --channel xfce4-panel --property '/plugins/plugin-2/grouping' --set '0'

# Update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Install
sudo apt-get install -y autojump
sudo apt-get install -y build-essential
sudo apt-get install -y cmake
sudo apt-get install -y command-not-found
sudo apt-get install -y git
sudo apt-get install -y htop
sudo apt-get install -y libtext-lorem-perl
sudo apt-get install -y pipx && pipx ensurepath
sudo apt-get install -y snapd
sudo apt-get install -y vim vim-python-jedi
sudo apt-get install -y zeal
sudo apt-get install -y zsh

# bluetooth
sudo apt install blueman bluez-* pulseaudio-module-bluetooth bluemon

# clean
sudo apt-get autoremove -y
sudo apt-get autoclean -y

# pyenv
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

# zsh
chsh -s $(which zsh)
# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# Docker
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# SSH
ssh-keygen -t rsa -b 4096 -C "lucas.cezimbra@gmail.com"

# .zshrc
mv ~/.zshrc ~/.zshrc_backup 2> /dev/null
echo ". $PWD/zshrc" >> ~/.zshrc
touch zshrc.local

# vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo "source $PWD/vimrc" >> ~/.vimrc

# nvimrc
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "source $PWD/nvimrc" >> ~/.config/nvim/init.vim
pip install pynvim

# .gitconfig
mv ~/.gitconfig ~/.gitconfig_backup 2> /dev/null
cp gitconfig ~/.gitconfig

# Rust
curl https://sh.rustup.rs -sSf | sh

# LunarVim
LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh)
mv ~/.config/lvim/config.lua ~/.config/lvim/config.lua.bkp
ln -s ./lvim.lua ~/.config/lvim/config.lua
pyenv virtualenv debugpy
pyenv shell debugpy
pip install debugpy

# mise
curl https://mise.jdx.dev/install.sh | sh

# startship
cargo install starship --locked

# thefuck
pipx install thefuck

# Firewall
sudo apt-get install ufw
sudo ufw default deny incoming

# eza
cargo install eza

# WezTerm
flatpak install flathub org.wezfurlong.wezterm
mv ~/.wezterm.lua ~/.wezterm_backup.lua 2> /dev/null
ln -s $PWD/wezterm.lua ~/.wezterm.lua
