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
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            { "<c-k>", mode = "i", false },
          },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- start from LazyVim's defaults if you want
      -- opts.keymap.preset = "enter"

      -- Example: completely disable a specific key
      opts.keymap["<C-K>"] = false
      opts.keymap["<c-k>"] = false

      -- or remap keys explicitly
      -- opts.keymap["<C-n>"] = { "select_next" }
      -- opts.keymap["<C-p>"] = { "select_prev" }

      return opts
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    specs = { "Kaiser-Yang/blink-cmp-avante" },
    opts = {
      sources = {
        default = { "avante" },
        providers = { avante = { module = "blink-cmp-avante", name = "Avante" } },
      },
    },
  },
}
