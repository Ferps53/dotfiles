local M = {}

M.plugins = {
	"https://github.com/stevearc/conform.nvim",
}

function M:setup()
	local conform = require("conform")

	conform.setup({
		formatters_by_ft = {
			java = { "google-java-format" },
			typescript = { "biome" },
			javascript = { "biome" },
			json = { "biome" },
			jsonc = { "biome" },
			scss = { "biome" },
			css = { "biome" },
			html = { "prettier" },
			angular = { "prettier" },
			lua = { "stylua" },
			nix = { "alejandra" },
			go = { "goimports", "gofumpt" },
		},
		formatters = {
			["google-java-format"] = {
				command = "google-java-format",
				args = { "-" },
				stdin = true,
			},
		},
	})
	local map = require("core.mapper").mapper()

	map("n", "<leader>gF", function()
		conform.format({ bufnr = vim.api.nvim_get_current_buf() })
	end)
end

return M
