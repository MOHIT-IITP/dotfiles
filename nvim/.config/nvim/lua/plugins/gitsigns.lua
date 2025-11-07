return {

  -- 🟢 Git Signs — inline diff markers, blame, status
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,

        -- Git blame text
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 500,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = " <author>, <author_time:%Y-%m-%d> - <summary>",

        -- Actions
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, "Next Hunk")

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, "Previous Hunk")

          -- Actions
          map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
          map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
          map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Selection")
          map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Selection")
          map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
          map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame Line")
          map("n", "<leader>hd", gs.diffthis, "Diff This")
          map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff Against HEAD")
        end,
      })
    end,
  },

  -- 🔵 Vim Fugitive — full Git command suite inside Neovim
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "GBrowse", "Gdiffsplit", "Gstatus" },
    keys = {
      { "<leader>gs", ":Git<CR>", desc = "Git status" },
      { "<leader>gc", ":Git commit<CR>", desc = "Git commit" },
      { "<leader>gp", ":Git push<CR>", desc = "Git push" },
      { "<leader>gl", ":Git pull<CR>", desc = "Git pull" },
      { "<leader>gb", ":Git blame<CR>", desc = "Git blame" },
      { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git diff split" },
    },
    config = function()
      -- Optional: integration tweaks
      vim.cmd([[
        nnoremap <leader>gm :Git mergetool<CR>
      ]])
    end,
  },

}
 
