return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  keys = {
    {
      ";e",
      "<cmd>Yazi<CR>",
      desc = "Open Yazi in current directory",
    },
    {
      "<leader>cw",
      "<cmd>Yazi cwd<CR>",
      desc = "Open Yazi in working directory",
    },
    {
      "<C-Up>",
      "<cmd>Yazi toggle<CR>",
      desc = "Resume Yazi session",
    },
  },

  opts = {
    -- Prevent opening Yazi automatically when entering directories.
    open_for_directories = false,

    keymaps = {
      show_help = "?",
    },
  },

  init = function()
    -- Disable netrw since Yazi replaces it.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
}
