vim.opt.relativenumber = true

lvim.log.level = "warn"
lvim.format_on_save.enabled = false
lvim.colorscheme = "lunar"

lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "javascript",
    "json",
    "lua",
    "python",
    "typescript",
    "tsx",
    "css",
    "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true

-- https://www.lunarvim.org/docs/configuration/language-features/language-servers#by-overriding-the-setup
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
require("lvim.lsp.manager").setup("pyright", {
    settings = {
        python = { analysis = { typeCheckingMode = "off" } },
    },
})

-- Additional Plugins
lvim.plugins = {
    {
        "ggandor/leap.nvim",
        config = function()
            require("leap").create_default_mappings()
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        "nvim-neotest/neotest",
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        args = { "-vv" },
                    }),
                },
            })
        end,
        dependencies = {
            "nvim-neotest/neotest-python",
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "kevinhwang91/nvim-bqf",
        event = { "BufRead", "BufNew" },
        config = function()
            require("bqf").setup({
                auto_enable = true,
                preview = {
                    win_height = 12,
                    win_vheight = 12,
                    delay_syntax = 80,
                    border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
                },
                func_map = {
                    vsplit = "",
                    ptogglemode = "z,",
                    stoggleup = "",
                },
                filter = {
                    fzf = {
                        action_for = { ["ctrl-s"] = "split" },
                        extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
                    },
                },
            })
        end,
    },
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            dap_python = require("dap-python")
            dap_python.setup("~/.pyenv/versions/debugpy/bin/python")
            dap_python.test_runner = "pytest"
        end,
    },
    {
        "romgrk/nvim-treesitter-context",
        config = function()
            require("treesitter-context").setup({
                enable = true,
                throttle = true,
                max_lines = 1,
                patterns = {
                    default = {
                        "class",
                        "function",
                        "method",
                    },
                },
            })
        end,
    },
    {
        "tiagovla/scope.nvim",
        config = function()
            require("scope").setup()
        end,
    },
    {
        "supermaven-inc/supermaven-nvim",
        config = function()
            require("supermaven-nvim").setup({
                keymaps = {
                    accept_suggestion = "<M-l>",
                    accept_word = "<M-a>",
                },
            })
        end,
    },
}
lvim.keys.normal_mode["<leader>g"] = ":Telescope live_grep<cr>"

lvim.builtin.which_key.mappings["dm"] = { ":lua require('neotest').run.run({strategy = 'dap'})<CR>", "Neotest Closest" }
lvim.builtin.which_key.mappings["df"] =
    { ":lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<CR>", "Neotest File" }

lvim.builtin.which_key.mappings["t"] = "+Test"
lvim.builtin.which_key.mappings["ta"] = { ":lua require('neotest').run.run(vim.fn.getcwd())<CR>", "Run All" }
lvim.builtin.which_key.mappings["tf"] = { ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", "Run File" }
lvim.builtin.which_key.mappings["tm"] = { ":lua require('neotest').run.run()<CR>", "Run Closest" }
lvim.builtin.which_key.mappings["to"] = { ":Neotest output<CR>", "Output" }
lvim.builtin.which_key.mappings["ts"] = { ":lua require('neotest').summary.toggle()<cr>", "Summary" }

lvim.keys.normal_mode["<C-t>"] = ":tabnew<CR>"
lvim.keys.normal_mode["gt"] = ":tabnext<CR>"
lvim.keys.normal_mode["gT"] = ":tabprev<CR>"
lvim.keys.normal_mode["gW"] = ":tabclose<CR>"

lvim.keys.normal_mode["<S-TAB>"] = ":bnext<CR>"

require("bufferline").setup({
    options = {
        always_show_bufferline = true,
    },
})
