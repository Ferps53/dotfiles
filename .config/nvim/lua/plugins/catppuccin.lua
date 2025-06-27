return {
	"catppuccin",
	lazy = false,
	name = "catppuccin",
	priority = 1000,
	opts = {
		transparent_background = true,
	},
	config = function()
		vim.cmd.colorscheme("catppuccin-macchiato")
    vim.cmd("highlight Normal guibg=none")
    vim.cmd("highlight NonText guibg=none")
	end,
}
