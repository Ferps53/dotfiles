return {
	{
		"catppuccin/nvim",
		priority = 1000,
		name = "catppucin",
		config = function()
			require("catppuccin").setup({})
		end,
	},
}
