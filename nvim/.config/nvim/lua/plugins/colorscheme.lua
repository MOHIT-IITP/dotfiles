return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- Can be: latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      no_italic = false,
      no_bold = false,
      no_underline = false,
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      color_overrides = {},
      custom_highlights = {},
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = true,
        mini = true,
        noice = true,
        mason = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        treesitter = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
        which_key = true,
        dap = {
          enabled = true,
          enable_ui = true,
        },
        aerial = true,
        dashboard = true,
        lsp_saga = false,
        semantic_tokens = true,
        illuminate = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  }
}




-- return {
--   {
--     "folke/tokyonight.nvim",
--     lazy = false, 
--     priority = 1000,
--     config = function()
--       require("tokyonight").setup({
--         style = "night", 
--         transparent = true,
--         terminal_colors = true, 
--         styles = {
--           comments = { italic = true },
--           keywords = { italic = true },
--           functions = {},
--           variables = {},
--         },
--         sidebars = { "qf", "help", "neo-tree", "terminal" }, 
--         dim_inactive = true, 
--         lualine_bold = true,
--       })
--       vim.cmd.colorscheme("tokyonight")
--     end,
--   },
--
--   -- Neo-tree plugin
--   {
--     "nvim-neo-tree/neo-tree.nvim",
--     branch = "v3.x",
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "nvim-tree/nvim-web-devicons",
--       "MunifTanjim/nui.nvim",
--     },
--     opts = {
--       -- Example: use_git_status_colors = false,
--       -- You can add custom Neo-tree config here if needed
--     },
--     lazy = false, 
--   },
-- }



-- ~/.config/nvim/lua/plugins/colorscheme.lua
-- return {
--   {
--     "bluz71/vim-nightfly-colors",
--     name = "nightfly",
--     lazy = false,
--     priority = 1000,
--     config = function()
--       -- Enable true color support
--       vim.opt.termguicolors = true
--
--       -- Optional customizations:
--       vim.g.nightflyItalics = 1        -- comments in italic (default true)
--       vim.g.nightflyCursorColor = 1    -- color the cursor
--       vim.g.nightflyNormalFloat = 1    -- apply theme to floating windows
--       vim.g.nightflyTerminalColors = 1 -- theme terminal windows too
--       vim.g.nightflyUndercurls = 1     -- undercurls for LSP/lint issues
--       vim.g.nightflyUnderlineMatchParen = 0
--       vim.g.nightflyVertSplits = 1     -- show vertical split columns
--       vim.g.nightflyTransparent = 0    -- solid background
--
--       -- Optionally tweak theme colors before loading
--       require("nightfly").custom_colors({
--         -- e.g., change violet to a brighter hue
--         -- violet = "#c792ea",
--       })
--
--       -- Load the colorscheme
--       vim.cmd([[colorscheme nightfly]])
--
--       -- Enhance aesthetic for LSP/hover windows
--       if vim.fn.has("nvim-0.8") == 1 then
--         vim.lsp.handlers["textDocument/hover"] =
--           vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
--         vim.lsp.handlers["textDocument/signatureHelp"] =
--           vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
--       end
--
--       -- Example: make functions bold via highlight override
--       vim.api.nvim_create_autocmd("ColorScheme", {
--         pattern = "nightfly",
--         callback = function()
--           vim.api.nvim_set_hl(0, "Function", { fg = require("nightfly").palette().blue, bold = true })
--         end
--       })
--     end,
--   },
-- }
