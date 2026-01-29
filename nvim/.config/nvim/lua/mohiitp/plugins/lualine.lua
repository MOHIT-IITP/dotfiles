return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    local colors = {
      bg = "#0f0f0f",
      fg = "#cfcfcf",
      gray = "#6b6b6b",
      darkgray = "#1c1c1c",
      white = "#ffffff",
    }

    local mode_map = {
      n = "N",
      i = "I",
      v = "V",
      V = "V",
      [""] = "V",
      c = "C",
      r = "R",
      R = "R",
      t = "T",
    }

    local function mode_short()
      return mode_map[vim.fn.mode()] or vim.fn.mode()
    end

    local tmux_theme = {
      normal = {
        a = { bg = colors.white, fg = colors.bg, gui = "bold" },
        b = { bg = colors.darkgray, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.gray },
      },
      insert = {
        a = { bg = colors.white, fg = colors.bg, gui = "bold" },
        b = { bg = colors.darkgray, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.gray },
      },
      visual = {
        a = { bg = colors.white, fg = colors.bg, gui = "bold" },
        b = { bg = colors.darkgray, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.gray },
      },
      replace = {
        a = { bg = colors.white, fg = colors.bg, gui = "bold" },
        b = { bg = colors.darkgray, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.gray },
      },
      command = {
        a = { bg = colors.white, fg = colors.bg, gui = "bold" },
        b = { bg = colors.darkgray, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.gray },
      },
      inactive = {
        a = { bg = colors.bg, fg = colors.gray },
        b = { bg = colors.bg, fg = colors.gray },
        c = { bg = colors.bg, fg = colors.gray },
      },
    }

    -- ======================
    -- ⚙️ SETUP
    -- ======================
    lualine.setup({
      options = {
        theme = tmux_theme,
        section_separators = "",   -- ❌ no arrows
        component_separators = "", -- ❌ no arrows
        globalstatus = true,
      },

      sections = {
        lualine_a = {
          { mode_short },
        },

        lualine_b = {
          { "branch", icon = "" },
        },

        lualine_c = {
          { "filename", path = 1 },
        },

        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
          },
          "encoding",
          "filetype",
        },

        lualine_y = {
          "progress",
        },

        lualine_z = {
          "location",
        },
      },
    })
  end,
}
