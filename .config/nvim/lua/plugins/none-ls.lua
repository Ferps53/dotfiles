return {
	"nvimtools/none-ls.nvim",
	config = function()

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
