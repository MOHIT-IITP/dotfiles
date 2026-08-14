return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            auto_install = true
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.opt.foldtext = ""
            vim.opt.fillchars:append("fold: ")
            vim.opt.foldlevelstart = 99
            vim.keymap.set("n", "zo", "zo", { desc = "Open fold" })
            vim.keymap.set("n", "zf", "zc", { desc = "Close fold" })
            vim.keymap.set("n", "zR", "zR", { desc = "Open all folds" })
        end,
    },
}
