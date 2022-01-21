# XFCE
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>d' --set 'thunar Downloads' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>f' --set 'thunar' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>r' --set 'xfce4-appfinder' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>s' --set 'mousepad Desktop/strings' --create --type 'string'
xfconf-query --channel xfce4-keyboard-shortcuts --property '/commands/custom/<Super>t' --set 'xfce4-terminal' --create --type 'string'
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
sudo apt-get install -y git
sudo apt-get install -y htop
sudo apt-get install -y libtext-lorem-perl
sudo apt-get install -y snapd
sudo apt-get install -y vim vim-python-jedi
sudo apt-get install -y zeal
sudo apt-get install -y zsh
# bluetooth
sudo apt install blueman bluez-* pulseaudio-module-bluetooth

# clean
sudo apt-get autoremove -y
sudo apt-get autoclean -y


# Install pyenv
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash


# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash


# zsh
chsh -s $(which zsh)
# oh-my-zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"


# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

# docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# # Install Hub
# wget https://github.com/github/hub/releases/download/v2.2.9/hub-linux-amd64-2.2.9.tgz
# tar -xvzf hub-linux-amd64-2.2.9.tgz
# sudo ./hub-linux-amd64-2.2.9/install
# rm -rf hub-linux-amd64-2.2.9 hub-linux-amd64-2.2.9.tgz


# SSH
ssh-keygen -t rsa -b 4096 -C "lucas.cezimbra@gmail.com"


# dotfiles
cd ~
git clone https://github.com/lucasrcezimbra/dotfiles .dotfiles
cd .dotfiles
sh ./install.sh
