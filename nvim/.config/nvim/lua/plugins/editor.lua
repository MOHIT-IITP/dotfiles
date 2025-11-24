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
		"vimpostor/vim-tpipeline",
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
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },

		opts = {
			signs = true, -- show icons in the gutter
			keywords = {
				TODO = { icon = " ", color = "info" },
				FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT" } },
				WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
				PERF = { icon = " ", color = "hint" },
				NOTE = { icon = "󰎚 ", color = "hint", alt = { "INFO" } },
				DONE = { icon = "󰄬 ", color = "success" },
			},
			highlight = {
				before = "", -- "fg" or "bg" or empty
				keyword = "bg",
				after = "fg",
			},
		},

		config = function(_, opts)
			require("todo-comments").setup(opts)
		end,
	},
}
