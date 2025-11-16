return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter", -- Load the plugin when you enter Insert mode
	dependencies = {
		-- Required sources for completion
		"hrsh7th/cmp-buffer", -- Buffer words
		"hrsh7th/cmp-path", -- File system paths
		"hrsh7th/cmp-nvim-lsp", -- LSP suggestions (requires nvim-lspconfig)

		-- Recommended for better UI/icons
		"saadparwaiz1/cmp_luasnip",
		"L3MON4D3/LuaSnip", -- Snippet engine

		-- Optional: for custom icons in the completion menu
		"onsails/lspkind.nvim",
	},

	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		cmp.setup({
			-- 1. Setup Sources
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- From active Language Servers
				{ name = "luasnip" }, -- From snippet engine
				{ name = "buffer" }, -- From text in the current buffer
				{ name = "path" }, -- From file paths
			}),

			-- 2. Setup Keymaps
			mapping = cmp.mapping.preset.insert({
				-- Select the next item
				["<C-n>"] = cmp.mapping.select_next_item(),
				-- Select the previous item
				["<C-p>"] = cmp.mapping.select_prev_item(),

				-- Use TAB/S-TAB for moving through menu and snippets
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					-- Use LuaSnip to jump to the next position in a snippet
					elseif luasnip.expand_or_locally_jumpable() then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					-- Use LuaSnip to jump to the previous position in a snippet
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),

				-- Confirm selection
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			}),

			-- 3. Setup Formatting/UI
			formatting = {
				format = lspkind.cmp_format({
					maxwidth = 50, -- Prevent horizontal scrollbars
					-- Use "verbose" for full type info (e.g., 'function', 'variable')
					-- or 'abbr' for just an icon
					mode = "symbol_text",
					menu = {
						buffer = "[Buffer]",
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						path = "[Path]",
					},
				}),
			},

			-- 4. Setup Snippets
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			-- 5. Other settings
			completion = {
				completeopt = "menu,menuone,noinsert", -- Neovim's completion options
			},

			-- Set the popup window border style
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
		})
	end,
}
