require("core")
require("packages")

vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	{ src = "https://github.com/julianolf/nvim-dap-lldb" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{
		src = "https://github.com/saghen/blink.cmp",
		version = "v1.10.2",
	},
	{ src = "https://github.com/vyfor/cord.nvim" },
	{ src = "https://github.com/iamcco/markdown-preview.nvim" },
})

require("dap-lldb").setup()
local dap, dapui = require("dap"), require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

vim.keymap.set({ "n" }, "<Leader>d", ":DapNew<CR>")
vim.keymap.set({ "n", "i" }, "<C-b>", ":DapToggleBreakpoint<CR>")

require("blink.cmp").setup({
	-- Use the pure-Lua fuzzy matcher: the prebuilt Rust lib isn't downloaded
	-- (blink is managed by vim.pack, not the release tarball).
	fuzzy = { implementation = "lua" },
	signature = { enabled = true },
	completion = {
		documentation = { auto_show = true, auto_show_delay_ms = 0 },
		menu = {
			auto_show = true,
			draw = {
				columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
			},
		},
	},
})
require("nvim-treesitter.install").compilers = { "gcc", "cc", "clang" }
require("nvim-treesitter").install({
	"java",
	"javascript",
	"typescript",
	"html",
	"css",
	"lua",
	"zig",
	"kotlin",
	"prisma",
	"nix",
	"markdown",
	"angular",
	"c",
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		require("packages.java_config"):start()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		local install_script = vim.api.nvim_get_runtime_file("app/install.sh", false)[1]

		if install_script then
			local app_dir = vim.fn.fnamemodify(install_script, ":h")

			local is_installed = vim.fn.isdirectory(app_dir .. "/bin") == 1

			if not is_installed then
				vim.notify(
					"Instalando servidor do Markdown Preview. Isso pode levar alguns segundos...",
					vim.log.levels.INFO
				)
				pcall(function()
					vim.fn["mkdp#util#install"]()
				end)
			end
		end
	end,
})
vim.g.mkdp_auto_close = 0
vim.g.mkdp_theme = "dark"
vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", { desc = "Abrir/Fechar previsão de markdown" })

vim.filetype.add({ extension = { html = "angular" } })
