local M = {}

M.plugins = {
	"https://github.com/neovim/nvim-lspconfig",
}

function M.setup()
	vim.lsp.enable({
		"lua_ls",
		"svelte",
		"zls",
		"lemminx",
		"biome",
		"ts_ls",
		"prismals",
		"angularls",
		"clangd",
		"kotlin_lsp",
	})

	-- JetBrains' official Kotlin LSP (IntelliJ-based): understands Java and Kotlin
	-- in the same project, unlike fwcd's kotlin-language-server.
	vim.lsp.config("kotlin_lsp", {
		cmd = {
			"kotlin-lsp",
			"--stdio",
			"--system-path",
			vim.fn.stdpath("cache") .. "/kotlin-lsp",
		},
		-- The server needs a real project model (Gradle/Maven import); a lone .kt
		-- buffer outside a project gives errors instead of useful diagnostics.
		single_file_support = false,
	})
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim", "hl" },
				},
				workspace = {
					library = vim.list_extend(
						vim.api.nvim_get_runtime_file("lua", true),
						{ "/run/current-system/sw/share/hypr/stubs" }
					),
					checkThirdParty = false,
				},
			},
		},
	})

	vim.lsp.config("clangd", {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--offset-encoding=utf-16",
		},
		root_markers = {
			"compile_commands.json",
			"compile_flags.txt",
			".clangd",
			"configure.ac",
			"Makefile",
			".git",
		},
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.hl", "hypr*.conf" },
		callback = function(event)
			vim.lsp.start({
				name = "hyprlang",
				cmd = { "hyprls" },
				root_dir = vim.fn.getcwd(),
				settings = {
					hyprls = {
						preferIgnoreFile = true, -- set to false to prefer `hyprls.ignore`
						ignore = { "hyprlock.conf", "hypridle.conf" },
					},
				},
			})
		end,
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client == nil then
				return
			end

			local opts = { buffer = event.buf }
			local fzf = require("fzf-lua")
			vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "gd", fzf.lsp_definitions, opts)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			vim.keymap.set("n", "gi", fzf.lsp_implementations, opts)
			vim.keymap.set("n", "gr", fzf.lsp_references, opts)
			vim.keymap.set("n", "gs", fzf.lsp_workspace_symbols, opts)
			vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>ca", fzf.lsp_code_actions, opts)
			vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>", opts)
			vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>", opts)
		end,
	})
end

return M
