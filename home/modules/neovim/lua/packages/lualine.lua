local M = {}

M.plugins = {
	"https://github.com/nvim-lualine/lualine.nvim",
}

function M.setup()
	require("lualine").setup({
		options = {
			theme = "catppuccin-macchiato",
		},
	})
end

return M
