-- 配色：Catppuccin，深色 Mocha / 浅色 Latte，跟随终端（与 Ghostty / tmux 统一）
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "auto",                              -- 跟随终端深浅色
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      integrations = { blink_cmp = true, snacks = true, which_key = true, mini = true, noice = true },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
