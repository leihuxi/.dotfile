# .dotfile

Personal config: zsh (oh-my-zsh + starship), tmux (oh-my-tmux), Neovim (LazyVim), vim ([leihuxi/vimrc](https://github.com/leihuxi/vimrc)), Ghostty, and Claude Code.
Supports **macOS** and **Arch Linux**.

## Install

### macOS

```sh
git clone https://github.com/leihuxi/.dotfile.git ~/.dotfile
cd ~/.dotfile && ./setup.sh
```

The script is safe to re-run. It:

- installs everything in the [`Brewfile`](Brewfile) with Homebrew (tmux, fzf, starship, eza, bat, fd, ripgrep, zoxide, delta, difftastic, lazygit, neovim, MacVim, Ghostty, fonts, formatters, …)
- installs or updates oh-my-zsh and its plugins (zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions, fzf-tab)
- installs or updates [oh-my-tmux](https://github.com/gpakosz/.tmux) (`~/.local/share/oh-my-tmux`, config in `~/.config/tmux/`)
- **symlinks** the config files into `$HOME`, backing up existing files to `~/.bakconfig/`
- installs the vim config (`./setup.sh vim` runs just that step)

Because everything is symlinked, edit and commit files in `~/.dotfile` directly.
Afterwards, `update` updates brew, oh-my-zsh, tmux plugins, nvim plugins, Mason tools and the rest in one go.

### Arch Linux

```sh
./setup.sh install   # system packages + third-party packages + dotfiles
./setup.sh dot       # dotfiles only
./setup.sh vim       # vim config only
./setup.sh           # update
```

## Files

| File | Purpose |
|---|---|
| `.zshrc` | zsh config (shared by macOS / Arch). Machine-local settings go in `~/.zshrc.local` |
| `.tmux.conf.local` | oh-my-tmux overrides: prefix `C-a` (IME-proof), vi keys, `C-h/j/k/l` shared with vim, popups, light/dark theme, plugins |
| `.config/nvim` | Neovim (LazyVim, leader `,`), including claudecode.nvim |
| `.bin/zsh/fzf_custom.zsh` | fzf helpers: `fe` `vg` `fcd` `fh` `fkill` `fbr` `fco` `fshow` `fstash` `tm` … |
| `.config/ghostty/config` | Ghostty terminal (theme follows macOS light/dark) |
| `.config/starship.toml` | prompt |
| `.gitconfig` | git: delta pager, difftastic aliases, modern defaults |
| `.claude/settings.json` | Claude Code: hooks (tmux flag, notifications, auto-format), status line, permissions |
| `.bin/claude-*` | Claude Code helpers: tmux status / notify, `claude-format`, `claude-statusline` |
| `.bin/tmux-sessionizer` | `prefix s` / `ts`: pick a session or project directory with fzf |
| `.bin/update` | update everything |
| `.cheatsheet.md` | key cheatsheet: run `cheat` or press `prefix ?` |
| `Brewfile` | macOS packages |
| `.config/{atuin,yazi,eza,lazygit,btop,gh-dash}` | history search, file manager, … all on Catppuccin |

## Keys

See [`.cheatsheet.md`](.cheatsheet.md), or run `cheat` in a terminal.
