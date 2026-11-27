-- 编辑增强
return {
  -- 保留 vim-surround 的 ys / cs / ds 习惯
  { "tpope/vim-surround", event = "VeryLazy" },
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- 补全：Tab / S-Tab 选择、回车确认（与 vim 的 coc 习惯一致）
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = { menu = { border = "rounded" }, documentation = { window = { border = "rounded" } } },
      signature = { window = { border = "rounded" } },
    },
  },

  -- 启动页标题
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                  , 键稍等弹出快捷键提示]],
        },
      },
    },
  },
}
