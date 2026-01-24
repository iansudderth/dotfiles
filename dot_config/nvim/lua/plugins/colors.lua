return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  
  -- add gruvbox-material
  { "sainnhe/gruvbox-material" },

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
