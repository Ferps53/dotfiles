local M = {}

M.plugins = {
	"https://github.com/nvim-lualine/lualine.nvim",
}

function M.setup()
	require("lualine").setup({
		options = {
			theme = "catppuccin",
		},
	})
end

return M
