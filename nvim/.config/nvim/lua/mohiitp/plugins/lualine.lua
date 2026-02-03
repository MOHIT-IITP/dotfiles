return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    local colors = {
      base = "#191724",
      surface = "#1f1d2e",
      overlay = "#26233a",
      muted = "#6e6a86",
      subtle = "#908caa",
      text = "#e0def4",
      love = "#eb6f92",
      gold = "#f6c177",
      rose = "#ebbcba",
      pine = "#31748f",
      foam = "#9ccfd8",
      iris = "#c4a7e7",
    }

    -----------------------------------------------------------------------
    -- MODE SHORT
    -----------------------------------------------------------------------
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

    -----------------------------------------------------------------------
    -- 🌹 ROSE PINE LUALINE THEME
    -----------------------------------------------------------------------
    local rose_pine_theme = {

      normal = {
        a = { bg = colors.iris, fg = colors.base, gui = "bold" },
        b = { bg = colors.overlay, fg = colors.text },
        c = { bg = colors.base, fg = colors.subtle },
      },

      insert = {
        a = { bg = colors.foam, fg = colors.base, gui = "bold" },
        b = { bg = colors.overlay, fg = colors.text },
        c = { bg = colors.base, fg = colors.subtle },
      },

      visual = {
        a = { bg = colors.rose, fg = colors.base, gui = "bold" },
        b = { bg = colors.overlay, fg = colors.text },
        c = { bg = colors.base, fg = colors.subtle },
      },

      replace = {
        a = { bg = colors.love, fg = colors.base, gui = "bold" },
        b = { bg = colors.overlay, fg = colors.text },
        c = { bg = colors.base, fg = colors.subtle },
      },

      command = {
        a = { bg = colors.gold, fg = colors.base, gui = "bold" },
        b = { bg = colors.overlay, fg = colors.text },
        c = { bg = colors.base, fg = colors.subtle },
      },

      inactive = {
        a = { bg = colors.base, fg = colors.muted },
        b = { bg = colors.base, fg = colors.muted },
        c = { bg = colors.base, fg = colors.muted },
      },
    }

    -----------------------------------------------------------------------
    -- ⚙️ SETUP
    -----------------------------------------------------------------------
    lualine.setup({
      options = {
        theme = rose_pine_theme,
        section_separators = "",   -- clean minimal
        component_separators = "", -- clean minimal
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
            color = { fg = colors.gold },
          },
          { "encoding", color = { fg = colors.subtle } },
          { "filetype", color = { fg = colors.subtle } },
        },

        lualine_y = {
          { "progress", color = { fg = colors.foam } },
        },

        lualine_z = {
          { "location", color = { fg = colors.text } },
        },
      },
    })
  end,
}
