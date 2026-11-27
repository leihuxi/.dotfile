-- 额外的 LSP：Swift 用 Xcode 自带的 sourcekit-lsp（mason 不提供）
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = { mason = false, filetypes = { "swift", "objc", "objcpp" } },
      },
    },
  },
}
