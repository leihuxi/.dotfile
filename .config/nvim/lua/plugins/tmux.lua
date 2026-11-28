-- tmux integration
return {
  -- C-h/j/k/l move between nvim splits and tmux panes (tmux side is configured)
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

  -- ,v* send code to the neighbouring tmux pane to run (same as the vim config)
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
            if not cmd then return vim.notify("no run command configured for " .. vim.bo.filetype, vim.log.levels.WARN) end
            vim.fn.VimuxRunCommand(cmd .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))
          end, desc = "Run File" },
      }
    end,
  },

  -- Session.vim (used by tmux-resurrect's @resurrect-strategy-nvim 'session')
  { "tpope/vim-obsession", cmd = "Obsession" },
}
