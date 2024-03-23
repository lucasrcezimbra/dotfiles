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
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
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
  {"mfussenegger/nvim-dap-python",
    config = function()
      dap_python = require("dap-python")
      dap_python.setup("~/.pyenv/versions/debugpy/bin/python")
      dap_python.test_runner = 'pytest'
    end,
  },
  {"zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = { keymap = { open = "<M-c>" } },
        suggestion = { auto_trigger = true },
      })
    end,
  },
  {"iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" },
  },

}
lvim.keys.normal_mode["<leader>g"] = ":Telescope live_grep<cr>"

lvim.keys.normal_mode["<leader>dm"] = ":lua require('dap-python').test_method()<CR>"
lvim.keys.normal_mode["<leader>dl"] = ":lua require('dap-python').test_class()<CR>"

lvim.keys.normal_mode["gt"] = ":BufferLineCycleNext<cr>"
lvim.keys.normal_mode["gT"] = ":BufferLineCyclePrev<cr>"
