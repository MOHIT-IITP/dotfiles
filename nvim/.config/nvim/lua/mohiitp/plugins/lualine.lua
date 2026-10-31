return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "echasnovski/mini.icons" },

  config = function()
    -- palettes are read from pywal when available, otherwise fall back to gruvbox
    local fallback = {
      colors = {
        color1 = "#cc241d",
        color2 = "#98971a",
        color3 = "#d79921",
        color4 = "#458588",
        color5 = "#b16286",
      },
      special = {
        background = "#1d2021",
        foreground = "#ebdbb2",
      },
    }

    local function read_wal_colors()
      local path = vim.fn.expand("~/.cache/wal/colors.json")
      if vim.fn.filereadable(path) == 0 then
        return nil
      end

      local ok, decoded = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
      if not ok or type(decoded) ~= "table" then
        return nil
      end

      return decoded
    end

    local wal_colors = read_wal_colors() or {}
    local colors = wal_colors.colors or fallback.colors
    local special = wal_colors.special or fallback.special

    -- short mode names
    local mode_map = {
      n = "NORMAL",
      i = "INSERT",
      v = "VISUAL",
      V = "VISUAL",
      [""] = "VISUAL",
      c = "COMMAND",
      r = "REPLACE",
      R = "REPLACE",
      t = "TERM",
    }

    local function mode_short()
      return mode_map[vim.fn.mode()] or vim.fn.mode()
    end


    -- short filetype names
    local filetype_map = {
      typescriptreact = "tsx",
      javascriptreact = "jsx",
      typescript = "ts",
      javascript = "js",
    }

    local function short_filetype()
      local ft = vim.bo.filetype
      return filetype_map[ft] or ft
    end

    local function file_info()
      local encoding = vim.bo.fileencoding
      local ft = short_filetype()

      if encoding == "" then
        return ft
      else
        return encoding .. " :: " .. ft
      end
    end

    local theme = {
      normal = {
        a = { bg = colors.color4, fg = special.background, gui = "bold" },
        b = { bg = colors.color2, fg = special.background },
        c = { bg = special.background, fg = special.foreground },
      },

      insert = {
        a = { bg = colors.color2, fg = special.background, gui = "bold" },
      },

      visual = {
        a = { bg = colors.color5, fg = special.background, gui = "bold" },
      },

      replace = {
        a = { bg = colors.color1, fg = special.background, gui = "bold" },
      },

      inactive = {
        a = { bg = special.background, fg = special.foreground },
        b = { bg = special.background, fg = special.foreground },
        c = { bg = special.background, fg = special.foreground },
      },
    }

    require("lualine").setup({
      options = {
        icons_enabled = false,
        theme = theme,
        component_separators = "",
        section_separators = "",
      },

      sections = {
        lualine_a = { mode_short },

        lualine_b = {
          "branch",
        },

        lualine_c = { "filename" },

        lualine_x = { file_info },

        lualine_y = { "progress" },

        lualine_z = { "location" },
      },
    })
  end,
}
