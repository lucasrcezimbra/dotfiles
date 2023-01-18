source ~/.dotfiles/vimrc

let g:python3_host_prog = "python"

call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
call plug#end()            " required


" telescope
nnoremap <leader>f <cmd>Telescope find_files<cr>

" always copy to clipboard
set clipboard=unnamedplus
