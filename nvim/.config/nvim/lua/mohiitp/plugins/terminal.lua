return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },

    opts = {
      size = 20,
      open_mapping = nil, -- we use our own mapping

      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = false,

      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,

      direction = "horizontal",

      float_opts = {
        border = "rounded",
        winblend = 0, -- change to 10-20 if you want transparency
      },
    },

    keys = {
      -- Toggle with leader tt
      {
        "<leader>tt",
        "<cmd>ToggleTerm<CR>",
        desc = "Toggle Terminal",
      },

      -- Close from inside terminal with same key
      {
        "<leader>tt",
        [[<C-\><C-n><cmd>ToggleTerm<CR>]],
        mode = "t",
        desc = "Toggle Terminal",
      },
    },
  },
}
