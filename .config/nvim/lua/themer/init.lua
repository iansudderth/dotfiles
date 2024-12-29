local colors = {
  black = 0,
  white = 15,
  red = 1,
  light_red = 9,
  green = 2,
  light_green = 10,
  yellow = 3,
  light_yellow = 11,
  blue = 4,
  light_blue = 12,
  magenta = 5,
  light_magenta = 13,
  cyan = 6,
  light_cyan = 14,
  light_grey = 7,
  dark_grey = 8,
}

--- @param name string
--- @param colors vim.api.keyset.highlight
local function highlight(name, colors)
  vim.api.nvim_set_hl(0, name, colors)
end

local function set()
  vim.cmd([[set notermguicolors]])

  highlight("Comment", { ctermfg = colors.light_grey })
end

return { set = set }
