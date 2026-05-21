local M = {}

M.plugins = {
  "https://github.com/ibhagwan/fzf-lua",
}

function M.setup()
  local icons = require("core.icons")
  local fzf = require("fzf-lua")
  fzf.setup({
    { "border-fused", "hide", "fzf-native" },
    defaults = {
      file_icons = icons.have_nerd_font and "devicons" or false,
    },
    fzf_opts = {
      ["--prompt"] = "  ",
      ["--pointer"] = icons.ui.fzf_pointer,
      ["--marker"] = icons.ui.fzf_marker,
    },
    oldfiles = {
      cwd_only = true,
      stat_file = true,
      include_current_session = true,
    },
    files = { prompt = " ", hidden = false },
    buffers = { prompt = icons.ui.fzf_buffer .. "  " },
    grep = {
      prompt = icons.ui.fzf_grep .. "  ",
      rg_glob = true,
      glob_flag = "--iglob",
      glob_separator = "%s%-%-",
    },
    winopts = {
      border = "single",
      title_pos = "center",
    },
    preview = {
      border = "single",
      scrollbar = false,
    },
    lsp = {
      prompt_postfix = " ",
      symbols = { symbol_icons = icons.lsp_kinds },
    },
  })

  local map = require("core.mapper").mapper()

	map("n", "<Leader>ff", function()
		if vim.fn.finddir(".git", vim.fn.getcwd() .. ";") ~= "" then
			fzf.files({ cmd = "git ls-files --cached --others --exclude-standard" })
		else
			fzf.files()
		end
	end, "Find files")
  map("n", "<Leader>fF", fzf.files, "Find all files")
  map("n", "<Leader>fg", fzf.live_grep, "Find grep")
  map("n", "<Leader>fw", fzf.grep_cword, "Find word")
  map("v", "<Leader>fw", fzf.grep_visual, "Find selection")
  map("n", "<Leader>fr", fzf.resume, "Find resume")
  map("n", "<Leader>fh", fzf.help_tags, "Find help")
  map("n", "<Leader>fo", fzf.oldfiles, "Find old files")
  map("n", "<Leader>fs", fzf.lsp_document_symbols, "Find document symbols")
  map("n", "<Leader>fS", fzf.lsp_workspace_symbols, "Find workspace symbols")
  map("n", "<Leader>fx", fzf.diagnostics_document, "Find document diagnostics")
  map("n", "<Leader>fX", fzf.diagnostics_workspace, "Find workspace diagnostics")
  map("n", "<Leader><Leader>", fzf.buffers, "Find buffers")
end

return M
