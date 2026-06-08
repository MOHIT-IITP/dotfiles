return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Custom Neovim ASCII Art
dashboard.section.header.val = {
  [[ █▄░█ █▀▀ █▀█  █░█  █ █▀▄▀█ ]],
  [[ █░▀█ ██▄ █▄█ ░█▄█░ █ █░▀░█ ]],
  [[                            ]],
  [[     ░░░░░ MOHIITP ░░░░░    ]],
}
    -- Buttons
    dashboard.section.buttons.val = {
      -- dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
      -- dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
      -- dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      -- dashboard.button("g", "  Grep text", ":Telescope live_grep<CR>"),
      -- dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
      -- dashboard.button("q", "  Quit", ":qa<CR>"),
    }

    -- Footer
    -- dashboard.section.footer.val = {
    --   "",
    --   "🚀 Neovim loaded successfully",
    -- }

    -- Styling
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"
    dashboard.section.footer.opts.hl = "Type"

    alpha.setup(dashboard.opts)
  end,
}
