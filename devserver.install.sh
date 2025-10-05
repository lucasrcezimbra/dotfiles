#!/bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
  user='lucas'
  echo "You are running as root and Claude doesn't accept dangerously mode using root user. Creating a '$user' user..."
  sudo adduser $user
  sudo usermod -aG sudo $user
  mkdir /home/$user/.ssh
  sudo cp /root/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
  chown -R $user:$user /home/$user/.ssh
  echo "Login again using $user"
  exit
fi

sudo echo || {
	echo "Your user is is not a superuser. Run the command below and restart your computer.
su -c 'sudo usermod -aG sudo $USER'";
	exit 1;
}

# Update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Essentials
sudo apt-get install -y git
sudo apt-get install -y postgresql-client-17  # psql
sudo apt-get install -y tmux

# Firewall
sudo apt-get install -y ufw
sudo ufw enable
sudo ufw allow 22
sudo ufw default deny incoming

# Docker
docker || {
  sudo apt-get install ca-certificates curl;
  sudo install -m 0755 -d /etc/apt/keyrings;
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc;
  sudo chmod a+r /etc/apt/keyrings/docker.asc;
  # shellcheck disable=all
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
  sudo apt-get update;
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;
}
sudo usermod -aG docker "$USER"

# mise and tools
curl https://mise.jdx.dev/install.sh | sh
echo "eval \"\$(~/.local/bin/mise activate bash)\"" >> ~/.bashrc
# shellcheck source=/dev/null
source ~/.bashrc
mise use node python
mise use -g gh node python

# Claude Code
npm install -g @anthropic-ai/claude-code
echo "alias claude='claude --dangerously-skip-permissions'" >> ~/.bashrc

# GitHub
gh auth login
