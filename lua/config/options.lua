-- File: lua/config/options.lua
local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.showmode = false
opt.splitbelow = true
opt.splitright = true

-- Behavior
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Files
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.updatetime = 50

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldcolumn = "1"
