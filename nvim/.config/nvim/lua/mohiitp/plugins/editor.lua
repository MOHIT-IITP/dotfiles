return {
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "javascript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "xml",
    },
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = true,
    },
  },

  -- Auto-close brackets, quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
    },
    config = function(_, opts)
      local autopairs = require("nvim-autopairs")
      autopairs.setup(opts)
    end,
  },
  {
    "echasnovski/mini.surround",
    version = false,
    event = "VeryLazy",

    opts = {
      custom_surroundings = nil,

      highlight_duration = 500,

      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",

        suffix_last = "l",
        suffix_next = "n",
      },

      n_lines = 20,

      respect_selection_type = false,

      search_method = "cover",

      silent = false,
    },

    config = function(_, opts)
      require("mini.surround").setup(opts)
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("notify").setup({
        stages = "fade_in_slide_out",
        timeout = 1500,
      })

      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true, -- search bar at bottom
          command_palette = true, -- position cmdline & popupmenu together
          long_message_to_split = true, -- long messages in split
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },
  -- this merge your bottom bar to the tmux bar
  -- {
    --   "vimpostor/vim-tpipeline",
    -- },
    {
      "norcalli/nvim-colorizer.lua",
    },
    {
      {
        'abecodes/tabout.nvim',
        lazy = false,
        config = function()
          require('tabout').setup {
            tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
            backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
            act_as_tab = true, -- shift content if tab out is not possible
            act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
            default_tab = '<C-t>', -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
            default_shift_tab = '<C-d>', -- reverse shift default action,
            enable_backwards = true, -- well ...
            completion = false, -- if the tabkey is used in a completion pum
            tabouts = {
              { open = "'", close = "'" },
              { open = '"', close = '"' },
              { open = '`', close = '`' },
              { open = '(', close = ')' },
              { open = '[', close = ']' },
              { open = '{', close = '}' }
            },
            ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
            exclude = {} -- tabout will ignore these filetypes
          }
        end,
        dependencies = { -- These are optional
          "nvim-treesitter/nvim-treesitter",
          "L3MON4D3/LuaSnip",
          "hrsh7th/nvim-cmp"
        },
        opt = true,  -- Set this to true if the plugin is optional
        event = 'InsertCharPre', -- Set the event to 'InsertCharPre' for better compatibility
        priority = 1000,
      },
      {
        "L3MON4D3/LuaSnip",
        keys = function()
          -- Disable default tab keybinding in LuaSnip
          return {}
        end,
      },
    },
  }
