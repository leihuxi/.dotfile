-- tmux 集成
return {
  -- C-h/j/k/l 在 nvim 分屏与 tmux pane 之间无缝切换（tmux 端已配置）
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/Pane Left" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/Pane Down" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/Pane Up" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/Pane Right" },
    },
    init = function() vim.g.tmux_navigator_save_on_switch = 1 end,
  },

  -- ,v* 把代码发到 tmux 旁边的 pane 执行（与 vim 配置相同）
  {
    "preservim/vimux",
    cmd = { "VimuxRunCommand", "VimuxPromptCommand", "VimuxRunLastCommand" },
    init = function()
      vim.g.VimuxOrientation = "h"
      vim.g.VimuxHeight = "40%"
      vim.g.VimuxUseNearest = 1
    end,
    keys = function()
      local runners = { python = "python3", sh = "bash", zsh = "zsh", javascript = "node", typescript = "npx tsx",
        go = "go run", ruby = "ruby", lua = "lua", rust = "cargo run" }
      return {
        { "<leader>v", "", desc = "+vimux" },
        { "<leader>vp", "<cmd>VimuxPromptCommand<cr>", desc = "Prompt Command" },
        { "<leader>vl", "<cmd>VimuxRunLastCommand<cr>", desc = "Run Last" },
        { "<leader>vi", "<cmd>VimuxInspectRunner<cr>", desc = "Inspect Runner" },
        { "<leader>vz", "<cmd>VimuxZoomRunner<cr>", desc = "Zoom Runner" },
        { "<leader>vq", "<cmd>VimuxCloseRunner<cr>", desc = "Close Runner" },
        { "<leader>vc", "<cmd>VimuxInterruptRunner<cr>", desc = "Interrupt Runner" },
        { "<leader>vs", function() vim.fn.VimuxRunCommand(vim.api.nvim_get_current_line()) end, desc = "Send Line" },
        { "<leader>vs", '"vy<cmd>call VimuxRunCommand(@v)<cr>', mode = "x", desc = "Send Selection" },
        { "<leader>vr", function()
            vim.cmd.update()
            local cmd = runners[vim.bo.filetype]
            if not cmd then return vim.notify("未配置 " .. vim.bo.filetype .. " 的运行命令", vim.log.levels.WARN) end
            vim.fn.VimuxRunCommand(cmd .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))
          end, desc = "Run File" },
      }
    end,
  },

  -- Session.vim（配合 tmux-resurrect 的 @resurrect-strategy-nvim 'session'）
  { "tpope/vim-obsession", cmd = "Obsession" },
}
