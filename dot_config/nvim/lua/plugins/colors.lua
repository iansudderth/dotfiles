return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- add gruvbox-material
  { "sainnhe/gruvbox-material" },

  -- add kanagawa
  { "rebelot/kanagawa.nvim" },

  {
    "HiPhish/rainbow-delimiters.nvim",
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
