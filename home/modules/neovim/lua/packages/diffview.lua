local M = {}

M.plugins = {
	"https://github.com/sindrets/diffview.nvim",
}

function M.setup()
	local icons = require("core.icons")

	require("diffview").setup({
		enhanced_diff_hl = true,
		file_panel = {
			listing_style = "tree",
			win_config = { width = 35 },
		},
		file_history_panel = {
			win_config = { height = 16 },
		},
		icons = {
			folder_closed = icons.ui.folder_closed,
			folder_open = icons.ui.folder_open,
		},
		signs = {
			fold_closed = icons.ui.fold_closed,
			fold_open = icons.ui.fold_open,
			done = icons.ui.ok,
		},
		file_status_icons = {
			added = icons.ui.diff_added,
			deleted = icons.ui.diff_deleted,
			modified = icons.ui.diff_modified,
			renamed = icons.ui.diff_renamed,
			copied = icons.ui.diff_copied,
			unmerged = icons.ui.diff_unmerged,
			unknown = icons.ui.diff_unknown,
		},
	})

	local map = require("core.mapper").mapper()

	map("n", "<Leader>gv", "<Cmd>DiffviewOpen<CR>", "Diffview open")
	map("n", "<Leader>gh", "<Cmd>DiffviewFileHistory %<CR>", "File history")
	map("n", "<Leader>gH", "<Cmd>DiffviewFileHistory<CR>", "Repo history")
	map("n", "<Leader>gx", "<Cmd>DiffviewClose<CR>", icons.label("Diffview close", icons.ui.diffview_close))
end

return M
