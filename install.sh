# .zshrc
mv ~/.zshrc ~/.zshrc_backup 2> /dev/null 
echo ". $PWD/zshrc" >> ~/.zshrc

# install vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
# .vimrc
echo "source $PWD/vimrc" >> ~/.vimrc

# Copy .gitconfig
mv ~/.gitconfig ~/.gitconfig_backup 2> /dev/null
cp gitconfig ~/.gitconfig
