-- Options on top of LazyVim's defaults (https://www.lazyvim.org/configuration/general)
vim.g.mapleader = ","            -- same as the vim config: leader = ,
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.scrolloff = 7
opt.relativenumber = true
opt.wrap = false
opt.spelllang = { "en", "cjk" }   -- spell check skips CJK text
opt.fileencodings = { "utf-8", "gbk", "gb18030", "latin1" }
