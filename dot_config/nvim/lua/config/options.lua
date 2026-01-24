-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard

-- Gruvbox configuration
vim.g.gruvbox_contrast_dark = "medium"
vim.g.gruvbox_contrast_light = "medium"
vim.g.gruvbox_bold = 1
vim.g.gruvbox_italic = 1
vim.g.gruvbox_underline = 1
vim.g.gruvbox_undercurl = 1
vim.g.gruvbox_invert_selection = 0
