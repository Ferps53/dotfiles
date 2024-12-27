return {
  "nvim-flutter/flutter-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim",
  },
  config = function ()
    require("flutter-tools").setup {}


    vim.keymap.set("n", "<leader>fR", "<CMD>FlutterRun<CR>")
    vim.keymap.set("n", "<leader>fd", "<CMD>FlutterDevices<CR>")
    vim.keymap.set("n", "<leader>fe", "<CMD>FlutterEmulators<CR>")
    vim.keymap.set("n", "<leader>fr", "<CMD>FlutterReload<CR>")
    vim.keymap.set("n", "<leader>fx", "<CMD>FlutterRestart<CR>")
    vim.keymap.set("n", "<leader>fcl", "<CMD>FlutterLspRestart<CR>")
  end,
}
