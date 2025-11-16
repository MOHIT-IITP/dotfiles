return {
	-- 1. Mason (Package Manager for LSPs, etc.)
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		opts = {
			-- You can customize Mason's settings here
		},
		config = function()
			require("mason").setup()
		end,
	},

	-- 2. Mason-LSPconfig (Bridges Mason and lspconfig)
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			-- List of language servers to ensure they are installed automatically
			auto_install = true,
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"pyright",
				"ts_ls",
				"html",
				"cssls",
			},
			-- Handlers are crucial for setting up the servers
			handlers = {
				-- Default handler: This will use the default nvim-lspconfig setup for every
				-- server Mason installs, unless a custom handler is defined below.
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,

				-- Example Custom Handler (Optional):
				-- You can define custom settings for specific LSPs here.
				["lua_ls"] = function()
					require("lspconfig").lua_ls.setup({
						settings = {
							Lua = {
								diagnostics = {
									-- Make Neovim's 'vim' global available to the language server
									globals = { "vim" },
								},
								workspace = {
									-- Tells lua_ls where to find the Neovim runtime library files
									library = vim.api.nvim_get_runtime_file("", true),
								},
							},
						},
					})
				end,
			},
		},
		-- Ensure the plugin is loaded before nvim-lspconfig
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},

	-- 3. nvim-lspconfig (Neovim's built-in LSP client configuration)
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		-- Lazy loading is typically handled by mason-lspconfig.nvim's automatic setup
	},
}
