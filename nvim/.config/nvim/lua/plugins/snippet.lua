return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets", -- huge collection of snippets
  },
  config = function()
    local luasnip = require("luasnip")
    local types = require("luasnip.util.types")

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Optional: Load your own custom snippets
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets" })

    -- Setup LuaSnip behavior
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
      ext_opts = {
        [types.choiceNode] = {
          active = { virt_text = { { "●", "Operator" } } },
        },
      },
    })

    -- Keybindings for snippet navigation
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true })

    vim.keymap.set("i", "<C-l>", function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end)

    -- Optional: nice visual feedback
    vim.cmd([[
      hi! link LuasnipChoiceNode PmenuSel
      hi! link LuasnipInsertNode Search
    ]])
  end,
}

