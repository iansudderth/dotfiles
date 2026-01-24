return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  {
    "HiPhish/rainbow-delimiters.nvim",
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}
