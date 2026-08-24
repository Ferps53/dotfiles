require("core")
require("packages")
print("Balls")

-- Disable unused language-host providers (not installed on this NixOS box).
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.keymap.set("n", "<Leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")
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
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.pick" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
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
})

require('lualine').setup({
  options = {
    theme = 'catppuccin'
  },
})

require('flutter-tools').setup({
  -- nixpkgs splits flutter and dart: <flutter_sdk>/bin/dart does not exist, so
  -- flutter-tools' auto-derived dartls cmd fails. Use the standalone `dart` on PATH.
  lsp = {
    cmd = { "dart", "language-server", "--protocol=lsp" },
  },
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

vim.keymap.set({ 'n' }, '<Leader>d', ':DapNew<CR>')
vim.keymap.set({ 'n', 'i' }, '<C-b>', ':DapToggleBreakpoint<CR>')


-- dcmls (Dart Code Metrics) omitted: the `dcm` binary isn't installed on this box.
vim.lsp.enable({ "lua_ls", "svelte", "zls", "lemminx", "biome", "ts_ls", "prismals", "angularls", "clangd",
  "kotlin_lsp" })

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
  -- Use the pure-Lua fuzzy matcher: the prebuilt Rust lib isn't downloaded
  -- (blink is managed by vim.pack, not the release tarball).
  fuzzy = { implementation = "lua" },
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
  "lua", "zig", "dart", "kotlin", "prisma", "nix", "markdown", "angular", "c"
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    require('packages.java_config'):start()
  end
})


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
