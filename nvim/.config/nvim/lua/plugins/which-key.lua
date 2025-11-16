return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		require("which-key").setup({})

		-- Minimal registration to show the leader key is active
		require("which-key").register({
			t = { name = "Telescope" },
			f = { name = "File" },
		}, {
			prefix = "<leader>",
		})
	end,
}
