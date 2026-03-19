return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim",{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make'} },

  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "❯ ",
        path_display = { "smart" },
        layout_config = { prompt_position = "bottom" },
        sorting_strategy = "descending",

        file_ignore_patterns = {
          "node_modules",
        },

        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--glob=!node_modules/*",
        },
      },
    })

    local keymap = vim.keymap.set

    -- 🔍 Basic
    keymap("n", "<leader>ft", "<cmd>Telescope builtin<CR>", { desc = "Telescope Builtins" })
    keymap("n", ";f", "<cmd>Telescope find_files<CR>", {})
    keymap("n", ";s", "<cmd>Telescope file_browser<CR>", {})
    keymap("n", ";r", builtin.live_grep, {})

    -- 🎨 Colorscheme picker with preview
    keymap("n", "<leader>fc", function()
      builtin.colorscheme({
        enable_preview = true, -- 🔥 live preview
      })
    end, { desc = "Colorscheme Picker" })
  end,
}


