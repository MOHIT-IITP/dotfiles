return {

  ---------------------------------------------------------------------------
  -- MASON (LSP/DAP/Formatter installer)
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- MASON-LSPCONFIG (Auto-install LSP servers)
  ---------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },

    opts = {
      ensure_installed = {
        -- IMPORTANT: TS servers removed here (ts_ls, vtsls)
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "html",
        "cssls",
        "jsonls",
        "tailwindcss",
        "eslint",
      },

      handlers = {

        -- DEFAULT: attach server with no custom settings
        function(server)
          require("lspconfig")[server].setup({})
        end,

        ---------------------------------------------------------------------
        -- Lua LSP (Neovim config support)
        ---------------------------------------------------------------------
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                telemetry = { enable = false },
              },
            },
          })
        end,

        ---------------------------------------------------------------------
        -- ESLint (Auto-fix on save)
        ---------------------------------------------------------------------
        ["eslint"] = function()
          require("lspconfig").eslint.setup({
            settings = { workingDirectory = { mode = "auto" } },
            on_attach = function(_, bufnr)
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "EslintFixAll",
              })
            end,
          })
        end,
      },
    },

    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },

  ---------------------------------------------------------------------------
  -- TypeScript / JavaScript LSP (BEST OPTION)
  ---------------------------------------------------------------------------
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    ft = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
      "tsx",
      "jsx",
    },

    opts = {
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          includeInlayParameterNameHints = "all",
        },
      },
    },

    config = function(_, opts)
      require("typescript-tools").setup(opts)
    end,
  },

  ---------------------------------------------------------------------------
  -- GLOBAL LSP UI (Keymaps + Diagnostics Setup)
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",

    config = function()
      -----------------------------------------------------------------------
      -- Keymaps (VS Code-style)
      -----------------------------------------------------------------------
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "gd", vim.lsp.buf.definition, opts)
      map("n", "gr", vim.lsp.buf.references, opts)
      map("n", "gi", vim.lsp.buf.implementation, opts)
      map("n", "K", vim.lsp.buf.hover, opts)
      map("n", "<leader>rn", vim.lsp.buf.rename, opts)
      map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      map("n", "[d", vim.diagnostic.goto_prev, opts)
      map("n", "]d", vim.diagnostic.goto_next, opts)

      -----------------------------------------------------------------------
      -- Diagnostic Icons
      -----------------------------------------------------------------------
      local signs = {
        Error = " ",
        Warn = " ",
        Info = " ",
        Hint = "󰌵 ",
      }

      for type, icon in pairs(signs) do
        vim.fn.sign_define(
          "DiagnosticSign" .. type,
          { text = icon, texthl = "DiagnosticSign" .. type, numhl = "" }
        )
      end

      vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}

