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

" Indent
autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType php setlocal shiftwidth=2 tabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

" Pydebug
command Pydebug :call Pydebug()
function! Pydebug()
	let trace = expand("import pdb; pdb.set_trace()")
	execute "normal o".trace
endfunction

let loaded_matchparen = 1 " Don't hightlight parentheses, brackets and braces

