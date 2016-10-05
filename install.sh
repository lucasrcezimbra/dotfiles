mv ~/.zshrc ~/.zshrc_backup 2> /dev/null 
echo ". $PWD/zshrc" >> ~/.zshrc

# Copy .gitconfig
mv ~/.gitconfig ~/.gitconfig_backup 2> /dev/null
cp gitconfig ~/.gitconfig
