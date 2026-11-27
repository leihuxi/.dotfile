-- 配色：Catppuccin Mocha（与 Ghostty / tmux / starship 统一）
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = { blink_cmp = true, snacks = true, which_key = true, mini = true, noice = true },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
