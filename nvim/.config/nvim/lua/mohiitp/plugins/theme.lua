-- return {
-- 	"rose-pine/neovim",
-- 	name = "rose-pine",
-- 	config = function()
-- 		vim.cmd("colorscheme rose-pine")
-- 	end
-- }
return {
  "AlphaTechnolog/pywal.nvim",
  config = function()
    require("pywal").setup()
  end
}
