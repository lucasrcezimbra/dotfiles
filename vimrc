set nocompatible              " be iMproved, required
filetype off                  " required

set number
set relativenumber

" Dont create .swp
set noswapfile

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'mattn/emmet-vim'
call vundle#end()            " required
filetype plugin indent on    " required
