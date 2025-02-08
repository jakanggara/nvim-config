-- File: lua/config/keymaps.lua
local map = vim.keymap.set

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Better searcher
map("n", "*", "*``")
map("n", "#", "#``")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- replace using highlighted text
map("n", "gR", "hy:%s/<C-r>h//gc<left><left><left>", { desc = "Replace using highlighted text" })
