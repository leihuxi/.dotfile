-- Extra LSP: Swift via Xcode's sourcekit-lsp (not available from mason)
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
