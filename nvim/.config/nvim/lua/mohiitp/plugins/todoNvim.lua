return {
  "MOHIT-IITP/todofloat.nvim",
  config = function()
    require("floattodo").setup({target_file = "~/moLib/todo.md"})
    vim.keymap.set("n", "<leader>dd", ":Td<CR>" , {silent=true})
  end
}
