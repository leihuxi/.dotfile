-- Colours: Catppuccin, Mocha when dark / Latte when light, following the terminal (matches Ghostty / tmux)
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "auto",                              -- follow the terminal background
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      integrations = { blink_cmp = true, snacks = true, which_key = true, mini = true, noice = true },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
