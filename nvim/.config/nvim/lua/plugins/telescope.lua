return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.x",
	-- Requires plenary for async operations
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local builtin = require("telescope.builtin")

		require("telescope").setup({}) -- Minimal setup

		-- Set keymaps for the most essential commands:

		-- <leader>ff: Find Files
		vim.keymap.set("n", ";f", builtin.find_files, { desc = "Find [F]iles" })

		-- <leader>fg: Live Grep (Search for text)
		vim.keymap.set("n", ";r", builtin.live_grep, { desc = "Live [G]rep" })

		-- <leader>fb: Find Buffers (Switch between open files)
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find [B]uffers" })
	end,
}
