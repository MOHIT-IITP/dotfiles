return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, for icons
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true, -- Close Neo-tree if it's the last window open
      enable_git_status = true,
      enable_diagnostics = true,

      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".git" },
        },
        follow_current_file = {
          enabled = true, -- highlight current file in tree
        },
        group_empty_dirs = true,
        hijack_netrw_behavior = "open_default",
      },

      window = {
        position = "right",
        width = 35,
        mappings = {
          ["<space>"] = "none",
          ["<CR>"] = "open",
          ["l"] = "open",
          ["h"] = "close_node",
          ["<C-r>"] = "refresh",
        },
      },
    })

    -- Keybinding to toggle tree
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
  end,
}
