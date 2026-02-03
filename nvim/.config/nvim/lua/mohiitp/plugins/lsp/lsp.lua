return {

  ---------------------------------------------------------------------------
  -- MASON (Installer)
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- MASON LSPCONFIG
  ---------------------------------------------------------------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },

    opts = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -----------------------------------------------------------------------
      -- ON ATTACH (Buffer-local keymaps)
      -----------------------------------------------------------------------
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end

        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "gi", vim.lsp.buf.implementation)
        map("n", "K", vim.lsp.buf.hover)
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
        map("n", "[d", vim.diagnostic.goto_prev)
        map("n", "]d", vim.diagnostic.goto_next)

        -- Enable inlay hints (Neovim 0.10+)
        if vim.lsp.inlay_hint then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      return {
        ensure_installed = {
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

          -------------------------------------------------------------------
          -- DEFAULT HANDLER
          -------------------------------------------------------------------
          function(server)
            require("lspconfig")[server].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end,

          -------------------------------------------------------------------
          -- LUA
          -------------------------------------------------------------------
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                Lua = {
                  diagnostics = { globals = { "vim" } },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                  },
                  telemetry = { enable = false },
                },
              },
            })
          end,

          -------------------------------------------------------------------
          -- ESLINT (Auto Fix on Save)
          -------------------------------------------------------------------
          ["eslint"] = function()
            require("lspconfig").eslint.setup({
              capabilities = capabilities,
              on_attach = function(client, bufnr)
                on_attach(client, bufnr)

                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = bufnr,
                  command = "EslintFixAll",
                })
              end,
              settings = {
                workingDirectory = { mode = "auto" },
              },
            })
          end,
        },
      }
    end,

    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },

  ---------------------------------------------------------------------------
  -- TYPESCRIPT / JAVASCRIPT (Best Setup)
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

    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("typescript-tools").setup({
        capabilities = capabilities,

        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = "insert_leave",

          tsserver_file_preferences = {
            includeCompletionsForModuleExports = true,
            includeInlayParameterNameHints = "all",
          },
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- GLOBAL LSP UI CONFIG
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",

    config = function()

      -----------------------------------------------------------------------
      -- Rounded Borders
      -----------------------------------------------------------------------
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -----------------------------------------------------------------------
      -- Diagnostic Icons
      -----------------------------------------------------------------------
      local signs = {
        Error = " ",
        Warn  = " ",
        Hint  = "󰌵 ",
        Info  = " ",
      }

      for type, icon in pairs(signs) do
        vim.fn.sign_define(
          "DiagnosticSign" .. type,
          { text = icon, texthl = "DiagnosticSign" .. type, numhl = "" }
        )
      end

      -----------------------------------------------------------------------
      -- Diagnostics UI
      -----------------------------------------------------------------------
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = "●",
        },
        float = {
          border = "rounded",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}

