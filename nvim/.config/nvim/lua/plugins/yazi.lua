return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",

  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },

  keys = {
    { ";e", "<cmd>Yazi<cr>", desc = "Open Yazi here" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open Yazi (cwd)" },
    { "<C-Up>", "<cmd>Yazi toggle<cr>", desc = "Resume Yazi" },
  },

  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "?",
    },
    -- Ensure Yazi uses its own keybindings by disabling conflicting ones
    hooks = {
      yazi_opened = function()
        -- Disable tmux navigation when yazi is open
        vim.g.tmux_navigator_no_mappings = 1
      end,
      yazi_closed_successfully = function()
        -- Re-enable tmux navigation when yazi is closed
        vim.g.tmux_navigator_no_mappings = 0
      end,
    },
  },

  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
