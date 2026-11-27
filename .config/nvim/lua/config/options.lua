-- 选项：在 LazyVim 默认值基础上调整（https://www.lazyvim.org/configuration/general）
vim.g.mapleader = ","            -- 与 vim 配置一致：leader = ,
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.scrolloff = 7
opt.relativenumber = true
opt.wrap = false
opt.spelllang = { "en", "cjk" }   -- 拼写检查忽略中文
opt.fileencodings = { "utf-8", "gbk", "gb18030", "latin1" }
