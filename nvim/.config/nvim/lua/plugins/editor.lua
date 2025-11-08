return {
  ---------------------------------------------------------------------------
  -- ⚙️ AUTO PAIRS + CUSTOM RULES + CMP INTEGRATION
  ---------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    opts = {
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel", "vim" },
      disable_in_macro = true,
      disable_in_visualblock = false,
      disable_in_replace_mode = true,
      ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
      enable_moveright = true,
      enable_afterquote = true,
      enable_check_bracket_line = true,
      enable_bracket_in_quote = true,
      enable_abbr = false,
      break_undo = true,
      check_ts = true,
      map_cr = true,
      map_bs = true,
      map_c_h = false,
      map_c_w = false,
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup(opts)

      -- Enhanced fast wrap
      npairs.setup({
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          pattern = [=[[%'%"%>%]%)%}%,]]=],
          offset = 0,
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
          manual_position = true,
        },
      })

      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp_status, cmp = pcall(require, "cmp")
      if cmp_status then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end

      -- ══════════════════════════════════════════════════════════════════
      -- CUSTOM PAIRING RULES
      -- ══════════════════════════════════════════════════════════════════

      -- Space inside pairs: ( | ) → (|)
      npairs.add_rules({
        Rule(" ", " ")
          :with_pair(function(opts)
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains({ "()", "[]", "{}" }, pair)
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return vim.tbl_contains({ "(  )", "[  ]", "{  }" }, context)
          end),

        -- Arrow functions: () => {}
        Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript", "javascriptreact" })
          :use_regex(true)
          :set_end_pair_length(2),

        -- Template literals in JS/TS
        Rule("${", "}", { "typescript", "typescriptreact", "javascript", "javascriptreact" })
          :with_pair(cond.not_before_text("`")),
      })

      -- Language-specific angle bracket rules
      local angle_bracket_filetypes = {
        "html", "xml", "svelte", "vue", "typescript", "typescriptreact",
        "javascript", "javascriptreact", "rust", "cpp", "c"
      }

      for _, ft in ipairs(angle_bracket_filetypes) do
        npairs.add_rules({
          Rule("<", ">", ft)
            :with_pair(cond.before_regex("%a+:?:?$", 3))
            :with_move(function(opts) return opts.char == ">" end),
        })
      end

      -- Markdown code blocks
      npairs.add_rules({
        Rule("```", "```", { "markdown", "vimwiki", "rmarkdown", "pandoc" })
          :with_cr(function(opts)
            return opts.line:match("^%s*```") ~= nil
          end),
      })

      -- LaTeX environments
      npairs.add_rules({
        Rule("\\begin{", "\\end{}", { "tex", "latex" })
          :use_regex(true)
          :with_pair(cond.not_before_text("\\end")),
      })

      -- Rust lifetime annotations
      npairs.add_rules({
        Rule("<'", "'>", "rust")
          :with_pair(function(opts)
            return opts.line:sub(opts.col - 1, opts.col - 1):match("[%w%)]") == nil
          end),
      })

      -- Better quote handling in comments
      for _, quote in ipairs({ '"', "'", "`" }) do
        npairs.add_rules({
          Rule(quote, quote)
            :with_pair(cond.not_inside_quote())
            :with_move(function(opts) return opts.char == quote end)
            :with_del(cond.none())
            :with_cr(cond.none())
            :use_key(quote)
        })
      end
    end,
  },

  ---------------------------------------------------------------------------
  -- 🏷️ AUTO CLOSE / RENAME HTML + JSX TAGS
  ---------------------------------------------------------------------------
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = {
      "html", "javascript", "javascriptreact", "typescript", "typescriptreact",
      "svelte", "vue", "tsx", "jsx", "rescript", "xml", "php", "markdown",
      "astro", "glimmer", "handlebars", "hbs", "eruby", "ejs", "htmldjango",
    },
    config = function()
      require("nvim-ts-autotag").setup({
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
        skip_tags = {
          "area", "base", "br", "col", "command", "embed", "hr", "img", "slot",
          "input", "keygen", "link", "meta", "param", "source", "track", "wbr",
          "menuitem", "circle", "ellipse", "line", "path", "polygon", "polyline",
          "rect", "stop", "use",
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 💬 COMMENT TOGGLING (Enhanced with treesitter integration)
  ---------------------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("Comment").setup({
        padding = true,
        sticky = true,
        ignore = "^$",
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
        extra = {
          above = "gcO",
          below = "gco",
          eol = "gcA",
        },
        mappings = {
          basic = true,
          extra = true,
        },
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🧩 SURROUND (quotes, tags, brackets) - Supercharged
  ---------------------------------------------------------------------------
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
          change_line = "cS",
        },
        surrounds = {
          -- HTML/JSX function wrapper
          ["f"] = {
            add = function()
              local result = require("nvim-surround.config").get_input("Function name: ")
              if result then
                return { { result .. "(" }, { ")" } }
              end
            end,
          },
          -- Template literal for JS/TS
          ["$"] = {
            add = { "${", "}" },
          },
          -- Markdown bold
          ["b"] = {
            add = { "**", "**" },
          },
          -- Markdown italic
          ["i"] = {
            add = { "*", "*" },
          },
          -- Markdown code
          ["c"] = {
            add = { "`", "`" },
          },
          -- LaTeX command
          ["l"] = {
            add = function()
              local cmd = require("nvim-surround.config").get_input("LaTeX command: ")
              if cmd then
                return { { "\\" .. cmd .. "{" }, { "}" } }
              end
            end,
          },
        },
        aliases = {
          ["a"] = ">",
          ["r"] = "]",
          ["c"] = "}",
          ["q"] = { '"', "'", "`" },
          ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
        highlight = {
          duration = 200,
        },
        move_cursor = "begin",
        indent_lines = true,
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 📏 INDENTATION GUIDE (v3 compatible)
  ---------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
        highlight = "IblIndent",
        smart_indent_cap = true,
        priority = 2,
      },
      whitespace = {
        highlight = "IblWhitespace",
        remove_blankline_trail = true,
      },
      scope = {
        enabled = true,
        char = "│",
        show_start = true,
        show_end = false,
        show_exact_scope = false,
        injected_languages = true,
        highlight = "IblScope",
        priority = 1024,
        include = {
          node_type = {
            ["*"] = { "*" },
          },
        },
      },
      exclude = {
        filetypes = {
          "help", "dashboard", "neo-tree", "Trouble", "lazy", "mason",
          "notify", "toggleterm", "lazyterm", "TelescopePrompt", "alpha",
          "lspinfo", "packer", "checkhealth", "man", "gitcommit", "NvimTree",
        },
        buftypes = {
          "terminal", "nofile", "quickfix", "prompt",
        },
      },
    },
    config = function(_, opts)
      require("ibl").setup(opts)

      -- Highlight customization
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
    end,
  },

  ---------------------------------------------------------------------------
  -- 🟡 HIGHLIGHT TODO / FIXME / NOTE (Enhanced)
  ---------------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
    config = function()
      local todo = require("todo-comments")
      
      todo.setup({
        signs = true,
        sign_priority = 8,
        keywords = {
          FIX = {
            icon = " ",
            color = "error",
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
          },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = {
            icon = " ",
            color = "warning",
            alt = { "WARNING", "XXX" },
          },
          PERF = {
            icon = " ",
            alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
          },
          NOTE = {
            icon = " ",
            color = "hint",
            alt = { "INFO" },
          },
          TEST = {
            icon = "⏲ ",
            color = "test",
            alt = { "TESTING", "PASSED", "FAILED" },
          },
        },
        gui_style = {
          fg = "NONE",
          bg = "BOLD",
        },
        merge_keywords = true,
        highlight = {
          multiline = true,
          multiline_pattern = "^.",
          multiline_context = 10,
          before = "",
          keyword = "wide",
          after = "fg",
          pattern = [[.*<(KEYWORDS)\s*:]],
          comments_only = true,
          max_line_len = 400,
          exclude = {},
        },
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
          test = { "Identifier", "#FF00FF" },
        },
        search = {
          command = "rg",
          args = {
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
          },
          pattern = [[\b(KEYWORDS):]], -- ripgrep regex pattern
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🎨 COLORIZE HEX CODES (Bonus)
  ---------------------------------------------------------------------------
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
        always_update = false,
      },
      buftypes = {},
    },
  },

  ---------------------------------------------------------------------------
  -- 🔍 BETTER TEXT OBJECTS (Bonus)
  ---------------------------------------------------------------------------
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" },
          e = {
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
  },
}
