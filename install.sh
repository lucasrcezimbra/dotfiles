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
