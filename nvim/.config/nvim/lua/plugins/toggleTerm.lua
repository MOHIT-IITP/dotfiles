return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- size of terminal
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,

      open_mapping = [[<leader>tf]], -- leader + tf
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,

      float_opts = {
        border = "rounded",
        winblend = 0,
      },
    })

    ------------------------------------------------------------------
    -- YAZI TOGGLE (leader + yt)
    ------------------------------------------------------------------
    local Terminal = require("toggleterm.terminal").Terminal

    local yazi = Terminal:new({
      cmd = "yazi",
      hidden = true,
      direction = "float",
      float_opts = {
        border = "rounded",
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.9)
        end,
      },
      on_open = function()
        vim.cmd("startinsert!")
      end,
      on_close = function()
        vim.cmd("stopinsert!")
      end,
    })

    vim.keymap.set("n", "<leader>yt", function()
      yazi:toggle()
    end, { desc = "Toggle Yazi File Manager" })

    ------------------------------------------------------------------
    -- Terminal mode keymaps (quality of life)
    ------------------------------------------------------------------
    function _G.set_terminal_keymaps()
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", [[<C-\><C-n>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end

    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}

