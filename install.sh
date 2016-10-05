cd ~
git clone https://github.com/Lrcezimbra/dotfiles ~/dotfiles
mv .zshrc .zshrc_backup

cd ~/dotfiles
ln -s zshrc ~/.zshrc
ln -s gitconfig ~/.gitconfig

