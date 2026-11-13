local M = {}

M.plugins = {
	"https://github.com/stevearc/oil.nvim",
}

function M.setup()
	require("oil").setup({
		lsp_file_methods = {
			enabled = true,
			timeout_ms = 1000,
			autosave_changes = true,
		},
		columns = {
			"icon",
		},
		float = {
			max_width = 0.3,
			max_height = 0.6,
			border = "rounded",
		},
		view_options = {
			show_hidden = true,
		},
	})
end

return M
