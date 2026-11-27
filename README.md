# .dotfile

个人配置：zsh（oh-my-zsh + starship）、tmux（oh-my-tmux）、vim（[leihuxi/vimrc](https://github.com/leihuxi/vimrc)）、Ghostty。
支持 **macOS** 和 **Arch Linux**。

## 安装

### macOS

```sh
git clone https://github.com/leihuxi/.dotfile.git ~/.dotfile
cd ~/.dotfile && ./setup.sh
```

脚本可以重复运行，会做这些事：

- 用 Homebrew 安装 [`Brewfile`](Brewfile) 里的软件（tmux、fzf、starship、eza、bat、fd、ripgrep、zoxide、delta、lazygit、vim、MacVim、Ghostty、Nerd Font…）
- 安装或更新最新的 oh-my-zsh 和插件（zsh-autosuggestions、zsh-syntax-highlighting、zsh-completions、fzf-tab）
- 安装或更新最新的 [oh-my-tmux](https://github.com/gpakosz/.tmux)（`~/.local/share/oh-my-tmux`，配置在 `~/.config/tmux/`）
- 把配置文件**软链接**到 `$HOME`，原有文件备份到 `~/.bakconfig/`
- 安装 vim 配置（`./setup.sh vim` 可单独执行）

因为是软链接，以后在 `~/.dotfile` 里改配置、提交就行。

### Arch Linux

```sh
./setup.sh install   # 系统包 + 第三方包 + dotfile
./setup.sh dot       # 只装 dotfile
./setup.sh vim       # 只装 vim 配置
./setup.sh           # 更新
```

## 文件

| 文件 | 说明 |
|---|---|
| `.zshrc` | zsh 配置（macOS / Arch 通用）。机器私有的设置放 `~/.zshrc.local` |
| `.tmux.conf.local` | oh-my-tmux 的自定义配置：前缀 `C-a`、vi 键位、`C-h/j/k/l` 与 vim 无缝切换、插件 |
| `.bin/zsh/fzf_custom.zsh` | fzf 函数：`fe` `vg` `fcd` `fh` `fkill` `fbr` `fco` `fshow` `fstash` `tm` … |
| `.config/ghostty/config` | Ghostty 终端 |
| `.config/starship.toml` | 提示符 |
| `.gitconfig` | git，diff 用 delta |
| `.cheatsheet.md` | 快捷键速查，终端里运行 `cheat` 查看 |
| `Brewfile` | macOS 软件清单 |

## 快捷键

见 [`.cheatsheet.md`](.cheatsheet.md)，或者终端里运行 `cheat`。
