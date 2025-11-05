return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "go", "javascript", "typescript", "tsx",
          "html", "css", "cpp", "java", "json", "python"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  }
  