-- Extra keys that keep vim habits (LazyVim defaults: https://www.lazyvim.org/keymaps)
local map = vim.keymap.set

-- ,w saves (replaces LazyVim's <leader>w window group; use <C-w> for windows)
pcall(vim.keymap.del, "n", "<leader>wd")
pcall(vim.keymap.del, "n", "<leader>wm")
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })

-- ,j* LSP (same keys as coc in vim)
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

-- ,S records the session to ./Session.vim (tmux-resurrect restores nvim from it)
map("n", "<leader>S", "<cmd>Obsession<cr>", { desc = "Toggle Session.vim (Obsession)" })

-- keep the selection after indenting in visual mode
map("x", "<", "<gv")
map("x", ">", ">gv")
