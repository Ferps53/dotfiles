return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", telescope.find_files, {})
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, {})
    end,
  },
  extensions = {
    fzf = {},
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        pickers = {

          find_files = {
            theme = "ivy",
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}
