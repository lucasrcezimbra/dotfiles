set nocompatible              " be iMproved, required
filetype off                  " required

let g:ycm_python_binary_path = 'python'    " Form YouCompleteMe
set noswapfile                             " Dont create .swp

" Show lines
set number
set relativenumber

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

Plugin 'mattn/emmet-vim'
Plugin 'nvie/vim-flake8'
Plugin 'scrooloose/syntastic'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()            " required
filetype plugin indent on    " required
