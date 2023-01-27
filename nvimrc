source ~/.dotfiles/vimrc

let g:python3_host_prog = "python"


call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
Plug 'lewis6991/gitsigns.nvim'
Plug 'RRethy/vim-illuminate'
Plug 'lunarvim/Onedarker.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'github/copilot.vim'
Plug 'dstein64/vim-startuptime'
Plug 'mhinz/vim-grepper'
call plug#end()            " required


" telescope
map <C-p> :Telescope find_files<cr>

" always copy to clipboard
set clipboard=unnamedplus

" vim-illuminate
set termguicolors
hi IlluminatedWordText guibg=Grey

" theme
colorscheme onedarker

" nvim-tree
lua require("nvim-tree").setup()
map <C-n> :NvimTreeToggle<CR>

" Grepper
map <F4> <plug>(GrepperOperator)
map <C-f> :Grepper<cr>
