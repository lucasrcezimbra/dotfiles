# .zshrc
mv ~/.zshrc ~/.zshrc_backup 2> /dev/null 
echo ". $PWD/zshrc" >> ~/.zshrc

# .vimrc
echo "source $PWD/vimrc" >> ~/.vimrc

# Copy .gitconfig
mv ~/.gitconfig ~/.gitconfig_backup 2> /dev/null
cp gitconfig ~/.gitconfig
