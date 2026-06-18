return {
  "MOHIT-IITP/todofloat.nvim",
  config = function()
    require("floattodo").setup({target_file = "~/Documents/Obsidian Vault/TODO.md"})
    vim.keymap.set("n", "<leader>dd", ":Td<CR>" , {silent=true})
  end
}
