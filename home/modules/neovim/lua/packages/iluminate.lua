local M = {}

M.plugins = {
	"https://github.com/RRethy/vim-illuminate",
}

function M.setup()
	require("illuminate").configure({
		providers = { "lsp", "treesitter", "regex" },
		delay = 100,
		under_cursor = true,
		large_file_cutoff = 2000,
		large_file_overrides = {
			providers = { "regex" },
		},
	})
end

return M
