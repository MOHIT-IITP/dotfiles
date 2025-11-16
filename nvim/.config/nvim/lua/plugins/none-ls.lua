return {
	"nvimtools/none-ls.nvim",
	-- Note: plenary.nvim is a required dependency.
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local null_ls = require("null-ls")
		local b = null_ls.builtins

		null_ls.setup({
			-- Minimal source list: only stylua for Lua formatting
			sources = {
				b.formatting.stylua,
			},

			-- Minimal on_attach hook for basic auto-formatting on save
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("NoneLSCoreFormat", { clear = true }),
						buffer = bufnr,
						callback = function()
							-- This formats the current buffer
							vim.lsp.buf.format({
								bufnr = bufnr,
								-- We filter to ensure only null-ls runs the formatter
								filter = function(c)
									return c.name == "null-ls"
								end,
							})
						end,
					})
				end
			end,
		})
	end,
}
