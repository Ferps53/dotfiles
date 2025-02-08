return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_install = { "lua_ls, jdtls" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"java-debug-adapter",
					"java-test",
				},
			})

			vim.api.nvim_command("MasonToolsInstall")

			local lspconfig = require("lspconfig")
			local capabilites = require("blink.cmp").get_lsp_capabilities()
			local lsp_attach = function(client, bufnr) end

			lspconfig.lua_ls.setup({
				capabilities = capabilites,
			})

			lspconfig.arduino_language_server.setup({
				cmd = {
					"arduino-language-server",
					"-cli-config",
					"~/.arduino15/arduino-cli.yaml",
					"-cli",
					"arduino-cli",
					"-clangd",
					"clangd",
					"-fqbn",
					"arduino:avr:uno",
				},
			})

			require("mason-lspconfig").setup_handlers({
				function(server_name)
					if server_name ~= "jdtls" then
						lspconfig[server_name].setup({
							on_attach = lsp_attach,
							capabilites = capabilites,
						})
					end
				end,
			})

			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {})
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
		end,
	},
}
