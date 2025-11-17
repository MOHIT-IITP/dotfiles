return {
	-- Auto close + auto rename HTML / JSX / TSX tags
	{
		"windwp/nvim-ts-autotag",
		ft = {
			"html",
			"javascript",
			"javascriptreact",
			"typescriptreact",
			"svelte",
			"vue",
			"xml",
		},
		opts = {
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = true,
		},
	},

	-- Auto-close brackets, quotes, and Blink.cmp integration
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true, -- enable Treesitter support
		},
		config = function(_, opts)
			local autopairs = require("nvim-autopairs")
			autopairs.setup(opts)

			-- Integration with Blink.cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("blink.cmp")

			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}
