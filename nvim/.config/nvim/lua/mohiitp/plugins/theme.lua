-- return {
-- 	"rose-pine/neovim",
-- 	name = "rose-pine",
-- 	config = function()
-- 		vim.cmd("colorscheme rose-pine")
-- 	end
-- }

-- return {
--   'uZer/pywal16.nvim',
--   -- for local dev replace with:
--   -- dir = '~/your/path/pywal16.nvim',
--   config = function()
--     vim.cmd.colorscheme("pywal16")
--   end,
-- }

return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  lazy = false,

  opts = {
    terminal_colors = true,
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
      strings = false,
      emphasis = true,
      comments = true,
      operators = false,
      folds = true,
    },
    strikethrough = true,

    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true,

    contrast = "hard", -- "hard", "soft", or ""

    palette_overrides = {},

    overrides = {
      -- Transparent backgrounds (optional)
      Normal = { bg = "NONE" },
      NormalFloat = { bg = "NONE" },
      SignColumn = { bg = "NONE" },
      EndOfBuffer = { bg = "NONE" },

      -- Cursor line
      CursorLine = { bg = "#3c3836" },

      -- Floating windows
      FloatBorder = { fg = "#928374", bg = "NONE" },

      -- Telescope
      TelescopeBorder = { fg = "#928374", bg = "NONE" },
      TelescopeNormal = { bg = "NONE" },
      TelescopePromptNormal = { bg = "NONE" },

      -- Neo-tree / Oil / Yazi compatibility
      NeoTreeNormal = { bg = "NONE" },
      NeoTreeNormalNC = { bg = "NONE" },
    },

    dim_inactive = false,
    transparent_mode = true,
  },

  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
