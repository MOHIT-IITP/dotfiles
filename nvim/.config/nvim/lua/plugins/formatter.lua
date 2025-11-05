return {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          go = { "gofmt" },
          cpp = { "clang_format" },
          java = { "google-java-format" },
        },
      })
    end,
  }
  