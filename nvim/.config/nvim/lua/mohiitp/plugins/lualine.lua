return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "echasnovski/mini.icons" },

  config = function()
    -- read pywal colors.json
    local wal_colors =
      vim.fn.json_decode(
        table.concat(
          vim.fn.readfile(vim.fn.expand("~/.cache/wal/colors.json")),
          "\n"
        )
      )

    local colors = wal_colors.colors
    local special = wal_colors.special

    -- short mode names
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

    -- tmux window name
    local function tmux_window()
      if vim.env.TMUX then
        local handle = io.popen("tmux display-message -p '#W' 2>/dev/null")
        if handle then
          local result = handle:read("*l")
          handle:close()
          if result ~= "" then
            return result
          end
        end
      end
      return ""
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
      local encoding = vim.o.fileencoding
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
          tmux_window,
        },

        lualine_c = { "filename" },

        lualine_x = { file_info },

        lualine_y = { "progress" },

        lualine_z = { "location" },
      },
    })
  end,
}
