-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-r>", vim.cmd.FlutterRestart)
vim.keymap.set("n", "<C-t>", vim.cmd.FlutterRun)
vim.keymap.set("n", "<C-l>", vim.cmd.FlutterLogClear)
