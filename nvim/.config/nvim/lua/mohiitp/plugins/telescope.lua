return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "❯ ",
        path_display = { "smart" },
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
    })

    -- keybindings
    local keymap = vim.keymap.set

    keymap("n", "<leader>ft", "<cmd>Telescope builtin <CR>", { desc = "Telescope Builtins" })
  end,
}
