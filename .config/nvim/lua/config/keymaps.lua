-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim.keymap.set("n", "<leader>p", function()
--   require("neoclip.fzf")()
-- end, { desc = "[P]aste from history" })
--
-- vim.keymap.set("i", "<C-p>", function()
--   require("neoclip.fzf")()
-- end, { desc = "paste from history" })
--

vim.keymap.set("n", "<leader>p", "<cmd>Telescope neoclip<cr>", { desc = "[P]aste from history" })

vim.keymap.set("i", "<C-p>", "<cmd>Telescope neoclip<cr>", { desc = "paste from history" })
