return {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "css",
          "scss",
          "html",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "lua",
          "vim",
          "go",
          "cpp",
          "java",
        },
        user_default_options = {
          RGB = true,       -- #RGB hex codes
          RRGGBB = true,    -- #RRGGBB hex codes
          names = true,     -- "blue" or "red"
          RRGGBBAA = true,  -- #RRGGBBAA hex codes
          rgb_fn = true,    -- rgb(), rgba()
          hsl_fn = true,    -- hsl(), hsla()
          css = true,       -- Enable all CSS features
          css_fn = true,    -- Enable all CSS *functions*
          mode = "background", -- Display mode: "background" | "foreground" | "virtualtext"
          tailwind = true,  -- ✅ Highlight Tailwind colors (bg-red-500, text-blue-400, etc.)
          always_update = true,
        },
      })
    end,
  }
  