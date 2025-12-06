return {
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

	-- Auto-close brackets, quotes
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
		},
		config = function(_, opts)
			local autopairs = require("nvim-autopairs")
			autopairs.setup(opts)
		end,
	},
	{
		"Wansmer/treesj",
		keys = { "<space>m", "<space>j", "<space>s" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesj").setup({})
		end,
	},
	{
		"echasnovski/mini.surround",
		version = false,
		event = "VeryLazy",

		opts = {
			custom_surroundings = nil,

			highlight_duration = 500,

			mappings = {
				add = "sa",
				delete = "sd",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				replace = "sr",

				suffix_last = "l",
				suffix_next = "n",
			},

			n_lines = 20,

			respect_selection_type = false,

			search_method = "cover",

			silent = false,
		},

		config = function(_, opts)
			require("mini.surround").setup(opts)
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("notify").setup({
				stages = "fade_in_slide_out",
				timeout = 2000,
			})

			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = true, -- search bar at bottom
					command_palette = true, -- position cmdline & popupmenu together
					long_message_to_split = true, -- long messages in split
					inc_rename = false,
					lsp_doc_border = true,
				},
			})
		end,
	},
}
