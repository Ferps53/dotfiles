require("core")
require("packages")

vim.keymap.set("n", "<Leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>gF", function()
  require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
end)
vim.keymap.set("n", "<leader>R", ":restart<CR>")

vim.g._start_time = vim.uv.hrtime()
local ok, ui2 = pcall(require, "vim._core.ui2")
if ok then
  ui2.enable({
    enable = true,
    msg = {
      target = "cmd",
      pager  = { height = 1 },
      msg    = { height = 0.5, timeout = 4500 },
      dialog = { height = 0.5 },
      cmd    = { height = 0.5 },
    }
  })
end

vim.pack.add({
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://codeberg.org/mfussenegger/nvim-jdtls" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/julianolf/nvim-dap-lldb" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = "v1.10.2",
  },
  { src = 'https://github.com/vyfor/cord.nvim', },
  { src = 'https://github.com/nvim-flutter/flutter-tools.nvim' },
  { src = 'https://github.com/iamcco/markdown-preview.nvim' },
  { src = 'https://github.com/stevearc/conform.nvim' },
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

vim.lsp.enable({ "lua_ls", "svelte-language-server", "zls", "lemminx", "dcm", "biome", "ts_ls", "prisma-ls", "angularls" })
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

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = { "*.hl", "hypr*.conf" },
  callback = function(event)
    vim.lsp.start {
      name = "hyprlang",
      cmd = { "hyprls" },
      root_dir = vim.fn.getcwd(),
      settings = {
        hyprls = {
          preferIgnoreFile = true, -- set to false to prefer `hyprls.ignore`
          ignore = { "hyprlock.conf", "hypridle.conf" }
        }
      }
    }
  end
})

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
require("blink.cmp").setup({
  signature = { enabled = true },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 0 },
    menu = {
      auto_show = true,
      draw = {
        columns = { { "kind_icon", "label", "label_description", gap = 1, }, { "kind" } },
      }
    }

  }
})
-- COMPLETION SETTINGS & KEYMAPS
-- Don't select the first item automatically, but show the menu
vim.keymap.set('n', '<leader>pf', ':Pick files<CR>')
vim.keymap.set('n', '<leader>h', ':Pick help<CR>')
vim.keymap.set('n', '-', ':Oil<CR>')

require("conform").setup({
  formatters_by_ft = {
    java       = { "google-java-format" },
    typescript = { "biome" },
    javascript = { "biome" },
    json       = { "biome" },
    jsonc      = { "biome" },
    scss       = { "biome" },
    css        = { "biome" },
    html       = { "prettier" },
    angular    = { "prettier" }
  },
  formatters = {
    ["google-java-format"] = {
      command = "google-java-format",
      args = { "-" },
      stdin = true,
    },
  },
})

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
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "g]", '<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>', opts)
    vim.keymap.set("n", "g[", '<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>', opts)
  end,

})

require("nvim-treesitter.install").compilers = { "gcc", "cc", "clang" }
require("nvim-treesitter").install({
  "java", "javascript", "typescript", "html", "css",
  "lua", "zig", "dart", "kotlin", "prisma", "nix", "markdown", "angular"
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

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

vim.filetype.add({ extension = { html = "angular" } })
