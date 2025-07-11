return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")

    config.setup({
      auto_install = { enable = true },
      ensure_installed = { "lua", "java" },
      highlight = { enable = true },
      ident = { enable = true },
    })
  end,
}
