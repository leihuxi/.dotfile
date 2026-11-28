-- Autocommands (LazyVim already has yank highlight, cursor restore, checktime, ...)

-- Input method: English on leaving insert mode, previous one restored on entering it (macOS, needs macism)
if vim.fn.executable("macism") == 1 then
  local english = "com.apple.keylayout.USExtended"
  local last = english
  local group = vim.api.nvim_create_augroup("ime_switch", { clear = true })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      vim.system({ "macism" }, { text = true }, function(r)
        last = vim.trim(r.stdout or "")
        if last ~= english and last ~= "" then
          vim.system({ "macism", english })
        end
      end)
    end,
  })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if last ~= english and last ~= "" then
        vim.system({ "macism", last })
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, {
    group = group,
    callback = function() vim.system({ "macism", english }) end,
  })
end
