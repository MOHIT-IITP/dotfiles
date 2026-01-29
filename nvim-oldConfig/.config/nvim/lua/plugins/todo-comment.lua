return {
	"folke/todo-comments.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-lua/plenary.nvim" },

	opts = {
		signs = true,

		keywords = {
			FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "ISSUE" } },
			TODO = { icon = " ", color = "info" },
			WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
			HACK = { icon = " ", color = "warning" },
			NOTE = { icon = "󰎚 ", color = "hint", alt = { "INFO", "NB" } },
			PERF = { icon = " ", color = "default", alt = { "OPTIMIZE", "PERFORMANCE" } },
			TEST = { icon = "⏱ ", color = "test", alt = { "PASSED", "FAILED" } },
			DONE = { icon = "󰄬 ", color = "info", alt = { "COMPLETED" } }, -- changed from "success"
		},

		highlight = {
			before = "",
			keyword = "wide",
			after = "fg",
			comments_only = true,
			max_line_len = 400,
		},

		search = {
			command = "rg",
			args = {
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
			},
			pattern = [[\b(KEYWORDS):]],
		},
	},

	config = function(_, opts)
		require("todo-comments").setup(opts)

		vim.keymap.set("n", "]t", function()
			require("todo-comments").jump_next()
		end, { desc = "Next TODO" })

		vim.keymap.set("n", "[t", function()
			require("todo-comments").jump_prev()
		end, { desc = "Prev TODO" })

		vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<CR>", { desc = "Search TODOs" })
	end,
}
