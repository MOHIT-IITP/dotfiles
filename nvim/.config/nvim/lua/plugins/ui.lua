return {
  ---------------------------------------------------------------------------
  -- 🎨 NOICE.NVIM - Modern UI Overhaul
  ---------------------------------------------------------------------------
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        },
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      notify = {
        enabled = true,
        view = "notify",
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = {
          enabled = true,
          silent = false,
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50,
          },
        },
        message = {
          enabled = true,
          view = "notify",
          opts = {},
        },
        documentation = {
          view = "hover",
          opts = {
            lang = "markdown",
            replace = true,
            render = "plain",
            format = { "{message}" },
            win_options = { concealcursor = "n", conceallevel = 3 },
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        -- Filter out noisy LSP messages
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d fewer lines" },
              { find = "%d more lines" },
            },
          },
          opts = { skip = true },
        },
        -- Route long messages to split
        {
          filter = {
            event = "msg_show",
            min_height = 20,
          },
          view = "split",
        },
        -- Route LSP progress to mini view
        {
          filter = {
            event = "lsp",
            kind = "progress",
            cond = function(message)
              local client = vim.tbl_get(message.opts, "progress", "client")
              return client == "lua_ls"
            end,
          },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    },
    keys = {
      { "<leader>sn", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>sd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = {"i", "n", "s"}},
    },
  },

  ---------------------------------------------------------------------------
  -- 🔔 NOTIFICATIONS (Enhanced)
  ---------------------------------------------------------------------------
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "fade_in_slide_out",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      render = "compact",
      background_colour = "#000000",
      fps = 60,
      level = vim.log.levels.INFO,
      minimum_width = 50,
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },
    },
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  ---------------------------------------------------------------------------
  -- 🎯 DRESSING.NVIM - Better vim.ui
  ---------------------------------------------------------------------------
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
    opts = {
      input = {
        enabled = true,
        default_prompt = "➤ ",
        prompt_align = "left",
        insert_only = true,
        start_in_insert = true,
        border = "rounded",
        relative = "cursor",
        prefer_width = 40,
        width = nil,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        win_options = {
          winblend = 0,
          wrap = false,
          list = true,
          listchars = "precedes:…,extends:…",
          sidescrolloff = 0,
        },
      },
      select = {
        enabled = true,
        backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
        trim_prompt = true,
        telescope = require("telescope.themes").get_dropdown({
          layout_config = { width = 0.8, height = 0.8 },
        }),
        fzf = {
          window = {
            width = 0.5,
            height = 0.4,
          },
        },
        builtin = {
          show_numbers = true,
          border = "rounded",
          relative = "editor",
          position = "50%",
          max_height = 0.8,
          min_height = { 10, 0.2 },
          width = nil,
          max_width = 0.8,
          min_width = { 40, 0.2 },
          win_options = {
            winblend = 0,
            cursorline = true,
            cursorlineopt = "both",
          },
        },
      },
    },
  },

  ---------------------------------------------------------------------------
  -- 🟢 STATUSLINE (Supercharged Lualine)
  ---------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "folke/noice.nvim",
    },
    opts = function()
      local icons = {
        diagnostics = {
          Error = " ",
          Warn = " ",
          Hint = " ",
          Info = " ",
        },
        git = {
          added = " ",
          modified = " ",
          removed = " ",
        },
      }

      local function diff_source()
        local gitsigns = vim.b.gitsigns_status_dict
        if gitsigns then
          return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed,
          }
        end
      end

      local function get_short_cwd()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      end

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "starter" },
          },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              fmt = function(str)
                return str:sub(1, 1)
              end,
            },
          },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = icons.git,
              source = diff_source,
            },
          },
          lualine_c = {
            {
              "diagnostics",
              symbols = icons.diagnostics,
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            {
              "filename",
              path = 1,
              symbols = { modified = "●", readonly = "", unnamed = "" },
            },
            -- LSP status
            {
              function()
                local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
                if #buf_clients == 0 then
                  return "LSP Inactive"
                end

                local buf_ft = vim.bo.filetype
                local buf_client_names = {}

                for _, client in pairs(buf_clients) do
                  if client.name ~= "null-ls" and client.name ~= "copilot" then
                    table.insert(buf_client_names, client.name)
                  end
                end

                local unique_client_names = table.concat(buf_client_names, ", ")
                local language_servers = string.format("[%s]", unique_client_names)

                return language_servers
              end,
              color = { gui = "italic" },
              separator = "",
            },
          },
          lualine_x = {
            -- Noice command/search status
            {
              require("noice").api.status.command.get,
              cond = require("noice").api.status.command.has,
              color = { fg = "#ff9e64" },
            },
            {
              require("noice").api.status.mode.get,
              cond = require("noice").api.status.mode.has,
              color = { fg = "#ff9e64" },
            },
            {
              require("noice").api.status.search.get,
              cond = require("noice").api.status.search.has,
              color = { fg = "#ff9e64" },
            },
            -- Working directory
            {
              get_short_cwd,
              icon = "",
              color = { gui = "italic" },
            },
            { "encoding" },
            {
              "fileformat",
              symbols = {
                unix = "",
                dos = "",
                mac = "",
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            {
              function()
                return " " .. os.date("%R")
              end,
            },
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = { "neo-tree", "lazy", "toggleterm", "mason", "trouble", "nvim-dap-ui" },
      }
    end,
  },

  ---------------------------------------------------------------------------
  -- 🟣 BUFFERLINE (Enhanced with Actions)
  ---------------------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "Delete buffers to the right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "Delete buffers to the left" },
      { "<leader>bd", "<cmd>bdelete<CR>", desc = "Delete buffer" },
    },
    opts = {
      options = {
        mode = "buffers",
        themable = true,
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 18,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        move_wraps_at_ends = false,
        separator_style = "slant",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        sort_by = "insert_after_current",
        offsets = {
          {
            filetype = "neo-tree",
            text = "󰙅 File Explorer",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "undotree",
            text = " Undo Tree",
            text_align = "center",
            separator = true,
          },
          {
            filetype = "DiffviewFiles",
            text = " Diff View",
            text_align = "center",
            separator = true,
          },
        },
        groups = {
          options = {
            toggle_hidden_on_enter = true,
          },
          items = {
            {
              name = "Tests",
              highlight = { underline = true, sp = "blue" },
              priority = 2,
              icon = "",
              matcher = function(buf)
                return buf.name:match("%.test") or buf.name:match("%.spec")
              end,
            },
            {
              name = "Docs",
              highlight = { underline = true, sp = "green" },
              priority = 2,
              icon = "",
              matcher = function(buf)
                return buf.name:match("%.md") or buf.name:match("%.txt")
              end,
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
      
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🎭 DASHBOARD / ALPHA (Startup Screen)
  ---------------------------------------------------------------------------
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = [[
                    ▀████▀▄▄              ▄█ 
                        █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█ 
                ▄        █          ▀▀▀▀▄  ▄▀  
               ▄▀ ▀▄      ▀▄              ▀▄▀ 
               ▄▀    █     █▀   ▄█▀▄      ▄█    
              ▀▄     ▀▄  █     ▀██▀     ██▄█   
               ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █  
                █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀  
               █   █  █      ▄▄           ▄▀   
      ]]

      dashboard.section.header.val = vim.split(logo, "\n")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
      }

      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8

      return dashboard
    end,
    config = function(_, dashboard)
      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🎨 INDENT SCOPE (Animated scope highlighting)
  ---------------------------------------------------------------------------
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      return {
        symbol = "│",
        options = { try_as_border = true },
        draw = {
          delay = 0,
          animation = require("mini.indentscope").gen_animation.none(),
        },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help", "alpha", "dashboard", "neo-tree", "Trouble", "trouble", "lazy",
          "mason", "notify", "toggleterm", "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🌈 RAINBOW DELIMITERS (Bracket colorization)
  ---------------------------------------------------------------------------
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
