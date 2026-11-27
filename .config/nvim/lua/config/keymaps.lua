-- 额外按键：保留在 vim 里的习惯（LazyVim 默认键位见 https://www.lazyvim.org/keymaps）
local map = vim.keymap.set

-- ,w 保存（取代 LazyVim 的 <leader>w 窗口组；窗口操作请用 <C-w>）
pcall(vim.keymap.del, "n", "<leader>wd")
pcall(vim.keymap.del, "n", "<leader>wm")
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })

-- ,j* LSP（与 vim 的 coc 键位相同）
map("n", "<leader>jj", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>jd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "<leader>je", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "<leader>jt", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
map("n", "<leader>jr", function() Snacks.picker.lsp_references() end, { desc = "References" })
map("n", "<leader>jn", vim.lsp.buf.rename, { desc = "Rename" })
map({ "n", "x" }, "<leader>jx", vim.lsp.buf.code_action, { desc = "Code Action / Fix" })
map("n", "<leader>jw", vim.lsp.buf.hover, { desc = "Hover Doc" })
map({ "n", "x" }, "<leader>jf", function() LazyVim.format({ force = true }) end, { desc = "Format" })
map("n", "<leader>jc", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
map("n", "<leader>ja", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "Switch Source/Header (C/C++)" })

-- ,S 记录会话到 ./Session.vim（tmux-resurrect 据此恢复 nvim）
map("n", "<leader>S", "<cmd>Obsession<cr>", { desc = "Toggle Session.vim (Obsession)" })

-- 可视模式缩进后保持选中
map("x", "<", "<gv")
map("x", ">", ">gv")
