vim.opt.number = true         -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true     -- Highlight current line
vim.opt.wrap = false          -- Don't wrap lines
vim.opt.scrolloff = 10        -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2        -- Tab width
vim.opt.shiftwidth = 2     -- Indent width
vim.opt.softtabstop = 2    -- Soft tab stop
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true  -- Case sensitive if uppercase in search
vim.opt.hlsearch = true   -- Don't highlight search results
vim.opt.incsearch = true  -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true                            -- Enable 24-bit colors
vim.opt.signcolumn = "yes"                              -- Always show sign column
vim.opt.colorcolumn = "100"                             -- Show column at 100 characters
vim.opt.showmatch = true                                -- Highlight matching brackets
vim.opt.matchtime = 2                                   -- How long to show matching bracket
vim.opt.cmdheight = 1                                   -- Command line height
vim.opt.completeopt = "menuone,noinsert,noselect,fuzzy" -- Completion options
vim.opt.showmode = false                                -- Don't show mode in command line
vim.opt.pumheight = 10                                  -- Popup menu height
vim.opt.pumblend = 10                                   -- Popup menu transparency
vim.opt.winblend = 0                                    -- Floating window transparency
vim.opt.conceallevel = 0                                -- Don't hide markup
vim.opt.concealcursor = ""                              -- Don't hide cursor line markup
vim.opt.lazyredraw = true                               -- Don't redraw during macros
vim.opt.synmaxcol = 300                                 -- Syntax highlighting limit

-- File handling
vim.opt.backup = false                            -- Don't create backup files
vim.opt.writebackup = false                       -- Don't create backup before writing
vim.opt.swapfile = false                          -- Don't create swap files
vim.opt.undofile = true                           -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
vim.opt.updatetime = 300                          -- Faster completion
vim.opt.timeoutlen = 500                          -- Key timeout duration
vim.opt.ttimeoutlen = 0                           -- Key code timeout
vim.opt.autoread = true                           -- Auto reload files changed outside vim
vim.opt.autowrite = false                         -- Don't auto save

-- Behavior settings
vim.opt.hidden = true                   -- Allow hidden buffers
vim.opt.errorbells = true               -- No error bells
vim.opt.backspace = "indent,eol,start"  -- Better backspace behavior
vim.opt.autochdir = false               -- Don't auto change directory
vim.opt.iskeyword:append("-")           -- Treat dash as part of word
vim.opt.path:append("**")               -- include subdirectories in search
vim.opt.selection = "exclusive"         -- Selection behavior
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.modifiable = true               -- Allow buffer modifications
vim.opt.encoding = "UTF-8"              -- Set encoding

vim.g.mapleader = " "

vim.diagnostic.config({
  virtual_lines = true,
})
vim.opt.guicursor =
"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/mason-org/mason-registry" },
  { src = "https://codeberg.org/mfussenegger/nvim-jdtls" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/julianolf/nvim-dap-lldb" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = "v1.*",
  },
  { src = 'https://github.com/vyfor/cord.nvim', },
  { src = 'https://github.com/nvim-flutter/flutter-tools.nvim' },
  { src = 'https://github.com/iamcco/markdown-preview.nvim' }
})

require('lualine').setup({
  options = {
    theme = 'catppuccin'
  },
})

require('flutter-tools').setup({})

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

vim.keymap.set({ 'n' }, '<Leader>d', ':DapNew<CR>')
vim.keymap.set({ 'n', 'i' }, '<C-b>', ':DapToggleBreakpoint<CR>')

require("catppuccin").setup({
  transparent_background = true
})

vim.cmd.colorscheme "catppuccin"
vim.lsp.enable({ "lua_ls", "svelte-language-server", "zls", "lemminx", "dcm", "biome", "ts_ls", "prisma-ls" })
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      }
    }
  }
})


require('cord').setup({
  display = {
    theme = 'catppuccin',
    flavor = 'accent'
  }
});

local minipick = require("mini.pick")
minipick.setup()
minipick.registry.file = function()
  local command = { 'rg', '--files', '--hidden', '--glob', '!.git/*' }
  return MiniPick.builtin.cli({ command = command }, { source = { name = 'Files' } })
end


require("oil").setup({
  lsp_file_methods = {
    enabled = true,
    timeout_ms = 1000,
    autosave_changes = true,
  },
  columns = {
    "icon",
  },
  float = {
    max_width = 0.3,
    max_height = 0.6,
    border = "rounded",
  },
  view_options = {
    show_hidden = true
  },
})
require("mason").setup()
require("blink.cmp").setup({
  signature = { enabled = true },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    menu = {
      auto_show = true,
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon", "label", "label_description", gap = 1, }, { "kind" } },
      }
    }

  }
})

-- COMPLETION SETTINGS & KEYMAPS
-- Don't select the first item automatically, but show the menu
vim.keymap.set('n', '<leader>f', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '-', ':Oil<CR>')
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format)

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client == nil then
      return
    end

    local opts = { buffer = event.buf }
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
    vim.keymap.set('n', 'gs', builtin.lsp_workspace_symbols, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'x' }, '=', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "g]", '<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>', opts)
    vim.keymap.set("n", "g[", '<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>', opts)
  end,

})

local status, ts = pcall(require, "nvim-treesitter")

if status then
  ts.setup({})

  ts.install({ "java", "javascript", "typescript", "html", "css", "lua", "zig", "dart", "kotlin", "prisma", "nix" })

  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      pcall(vim.treesitter.start)
    end
  })

else
  print("nvim-treesitter failed to load")
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    require('java_config')
        .setup()
  end
})

require("catppuccin").setup({
  transparent_background = true,
})

vim.cmd.colorscheme "catppuccin"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local install_script = vim.api.nvim_get_runtime_file("app/install.sh", false)[1]

    if install_script then
      local app_dir = vim.fn.fnamemodify(install_script, ":h")

      local is_installed = vim.fn.isdirectory(app_dir .. "/bin") == 1

      if not is_installed then
        vim.notify("Instalando servidor do Markdown Preview. Isso pode levar alguns segundos...", vim.log.levels.INFO)
        pcall(function()
          vim.fn["mkdp#util#install"]()
        end)
      end
    end
  end
})
vim.g.mkdp_auto_close = 0
vim.g.mkdp_theme = 'dark'
vim.keymap.set('n', '<leader>mp', ':MarkdownPreviewToggle<CR>', { desc = 'Abrir/Fechar previsão de markdown' })
