set nocompatible              " be iMproved, required
filetype off                  " required

set noswapfile " Dont create .swp
set hlsearch   " Highlight search

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
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'chrisbra/Colorizer'
Plugin 'tpope/vim-commentary'
Plugin 'Raimondi/delimitMate'
Plugin 'Yggdroot/indentLine'
Plugin 'sheerun/vim-polyglot'
" Plugin 'davidhalter/jedi-vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'raimon49/requirements.txt.vim'
Plugin 'ctrlpvim/ctrlp.vim'
call vundle#end()            " required
filetype plugin indent on    " required

" Indentation
autocmd FileType html setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType php setlocal expandtab shiftwidth=2 softtabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4

" Pydebug
command Pydebug :call Pydebug()
function! Pydebug()
	let trace = expand("import ipdb; ipdb.set_trace()")
	execute "normal o".trace
endfunction

let loaded_matchparen = 1 " Don't highlight parentheses, brackets and braces

let g:colorizer_auto_color = 1 " Color hex colors in css

" ColorColumn 80
highlight ColorColumn ctermbg=DarkGrey
set colorcolumn=80
