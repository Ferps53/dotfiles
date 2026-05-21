local M = {}

M.have_nerd_font = vim.g.have_nerd_font

function M.pick(glyph, ascii)
	return M.have_nerd_font and glyph or ascii
end

function M.label(text, glyph, ascii)
	if M.have_nerd_font then
		return string.format("%s %s", glyph, text)
	end
	if ascii and ascii ~= "" then
		return string.format("%s %s", ascii, text)
	end
	return text
end

M.ui = {
	ok = M.pick("󰄳", "OK"),
	pending = M.pick("󰦖", ".."),
	off = M.pick("󰚌", "x"),
	running = M.pick("󰑮", "R"),
	skipped = M.pick("󰒝", "S"),
	passed = M.pick("󰄳", "P"),
	failed = M.pick("󰅚", "F"),
	unknown = M.pick("", "?"),
	breakpoint = M.pick("󰝤", "B"),
	breakpoint_condition = M.pick("󰟃", "?"),
	breakpoint_rejected = M.pick("󰜺", "!"),
	stopped = M.pick("󰐊", ">"),
	diagnostic_error = M.pick(" ", "E "),
	diagnostic_warn = M.pick(" ", "W "),
	diagnostic_info = M.pick(" ", "I "),
	diagnostic_hint = M.pick("󰌵 ", "H "),
	folder_closed = M.pick("󰉋 ", "D "),
	folder_open = M.pick("󰝰 ", "O "),
	fold_closed = M.pick(" ", "> "),
	fold_open = M.pick(" ", "v "),
	diff_added = M.pick("󰐕 ", "+ "),
	diff_deleted = M.pick("󰍴 ", "- "),
	diff_modified = M.pick("󰏫 ", "~ "),
	diff_renamed = M.pick("󰑕 ", "R "),
	diff_copied = M.pick("󰆏 ", "C "),
	diff_unmerged = M.pick("󰘬 ", "U "),
	diff_unknown = M.pick("󰞋 ", "? "),
	git_ignored = M.pick("󰘓", "!"),
	git_untracked = M.pick("󰞋", "?"),
	git_added = M.pick("󰐕", "A"),
	git_copied = M.pick("󰆏", "C"),
	git_deleted = M.pick("󰍴", "D"),
	git_modified = M.pick("󰏫", "M"),
	git_renamed = M.pick("󰑕", "R"),
	type_changed = M.pick("󰉼", "T"),
	git_conflict = M.pick("󰘬", "U"),
	todo_fix = M.pick("󰅚 ", "F "),
	todo_todo = M.pick(" ", "T "),
	todo_hack = M.pick("󰈸 ", "H "),
	todo_warn = M.pick(" ", "W "),
	todo_perf = M.pick("󰅒 ", "P "),
	todo_note = M.pick("󰍨 ", "N "),
	todo_test = M.pick("󰙨 ", "T "),
	fzf_pointer = M.pick("❯", ">"),
	fzf_marker = M.pick("󰄳", "*"),
	fzf_buffer = M.pick("󰓩", "B"),
	fzf_grep = M.pick("󰍉", "G"),
	gitsigns_add = M.pick("▎", "|"),
	gitsigns_change = M.pick("▎", "|"),
	gitsigns_changedelete = M.pick("▎", "|"),
	gitsigns_delete = M.pick("", "-"),
	gitsigns_topdelete = M.pick("", "-"),
	gitsigns_untracked = M.pick("▎", "|"),
	diffview_close = M.pick("󰅚", "X"),
	color_swatch = "■",
}

M.lsp_kinds = {
	Array = M.pick(" ", "A "),
	Boolean = M.pick(" ", "B "),
	Class = M.pick(" ", "C "),
	Constant = M.pick(" ", "C "),
	Constructor = M.pick(" ", "C "),
	Enum = M.pick(" ", "E "),
	EnumMember = M.pick(" ", "E "),
	Event = M.pick(" ", "E "),
	Field = M.pick(" ", "F "),
	File = M.pick(" ", "F "),
	Function = M.pick(" ", "F "),
	Interface = M.pick(" ", "I "),
	Key = M.pick(" ", "K "),
	Keyword = M.pick(" ", "K "),
	Method = M.pick(" ", "M "),
	Module = M.pick(" ", "M "),
	Namespace = M.pick(" ", "N "),
	Null = M.pick(" ", "0 "),
	Number = M.pick(" ", "# "),
	Object = M.pick(" ", "O "),
	Operator = M.pick(" ", "+ "),
	Package = M.pick(" ", "P "),
	Property = M.pick(" ", "P "),
	Reference = M.pick(" ", "R "),
	Snippet = M.pick(" ", "S "),
	String = M.pick(" ", "S "),
	Struct = M.pick(" ", "S "),
	Text = M.pick(" ", "T "),
	TypeParameter = M.pick(" ", "T "),
	Unit = M.pick(" ", "U "),
	Value = M.pick(" ", "V "),
	Variable = M.pick(" ", "V "),
}

M.wk = {
	breadcrumb = M.pick("»", ">"),
	separator = M.pick("➜", "->"),
	ellipsis = M.pick("…", "..."),
}

M.aerial = {
	mid = "├─",
	last = "└─",
	nested = "│ ",
	space = "  ",
}

M.starter = {
	calendar = M.pick(" ", ""),
	morning = M.pick(" ", ""),
	afternoon = M.pick(" ", ""),
	evening = M.pick(" ", ""),
	find = M.pick("󰈞 ", ""),
	grep = M.pick("󰍉 ", ""),
	recent = M.pick("󱋡 ", ""),
	sessions = M.pick("󰀓 ", ""),
	new = M.pick("󰝒 ", ""),
	quit = M.pick("󰿅 ", ""),
	startup = M.pick("󰔛 ", "~"),
	plugins = M.pick(" ", "#"),
	neovim = M.pick(" ", "NV"),
}

M.groups = {
	aerial = { glyph = "󰨳", ascii = "A" },
	markdown = { glyph = "󰍔", ascii = "M" },
	buffer = { glyph = M.ui.fzf_buffer, ascii = "B" },
	code = { glyph = "󰘦", ascii = "C" },
	debug = { glyph = "󰃤", ascii = "D" },
	delete = { glyph = "󰆴", ascii = "X" },
	explorer = { glyph = M.ui.folder_closed, ascii = "E" },
	find = { glyph = M.ui.fzf_grep, ascii = "F" },
	git = { glyph = "󰊢", ascii = "G" },
	java = { glyph = "", ascii = "J" },
	extract = { glyph = "󰆏", ascii = "E" },
	lsp = { glyph = "󰒋", ascii = "L" },
	neotest = { glyph = M.ui.todo_test:gsub("%s+$", ""), ascii = "N" },
	pack = { glyph = "󰏗", ascii = "P" },
	refactor = { glyph = "󰁨", ascii = "R" },
	split = { glyph = "󰤻", ascii = "S" },
	session = { glyph = "󰁯", ascii = "S" },
	toggle = { glyph = "󰔡", ascii = "T" },
	trouble = { glyph = "󰙅", ascii = "X" },
	next = { glyph = "", ascii = "N" },
	prev = { glyph = "", ascii = "P" },
}

function M.group_label(name, text)
	local group = M.groups[name]
	if not group then
		return text
	end
	return M.label(text, group.glyph, group.ascii)
end

return M
