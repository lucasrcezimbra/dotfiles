-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<S-TAB>", ":bnext<CR>")

vim.keymap.set("v", "<leader>mt", ":!column -t -s '|' -o '|'<CR>", { desc = "Format table" })

vim.keymap.set("v", "<leader>p", [["_dP]], { desc = "Paste without yanking" })
