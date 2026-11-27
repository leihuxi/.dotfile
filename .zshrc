# ~/.zshrc — https://github.com/leihuxi/.dotfile  (macOS + Arch Linux)
# 机器私有的配置放 ~/.zshrc.local（不入库）

# Homebrew
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# -- proxy ---------------------------------------------------------------------
if [[ $OSTYPE == darwin* ]]; then
  export https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 all_proxy=socks5://127.0.0.1:7897
  export no_proxy=localhost,127.0.0.1,::1
fi

# -- oh-my-zsh -----------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                          # 提示符交给 starship（未安装时回退到 robbyrussell）
(( $+commands[starship] )) || ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode reminder    # 有新版本时提醒，运行 omz update 更新
zstyle ':omz:update' frequency 7
COMPLETION_WAITING_DOTS="true"
HYPHEN_INSENSITIVE="true"
DISABLE_MAGIC_FUNCTIONS="true"        # 粘贴 URL 更快

# vi-mode：普通/插入模式切换光标形状，Esc 切换更快
VI_MODE_SET_CURSOR=true
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
KEYTIMEOUT=15

# 补全
fpath=("$ZSH/custom/plugins/zsh-completions/src" /opt/homebrew/share/zsh/site-functions $fpath)

# autosuggestions：异步、大缓冲时不建议
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"        # 自动建议用终端的暗灰色（随深浅主题变化），不抢眼

# 系统深浅色（Ghostty 主题跟随系统；这里给 fzf / 语法高亮等只读一次的配色用，新开 shell 生效）
if [[ $OSTYPE == darwin* ]] && [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) != Dark ]]; then
  _theme=light
else
  _theme=dark
fi

# fzf-tab 须在 autosuggestions / syntax-highlighting 之前；syntax-highlighting 放最后
plugins=(git wd fzf colored-man-pages vi-mode sudo)
if [[ $OSTYPE == darwin* ]]; then
  plugins+=(macos)
elif (( $+commands[pacman] )); then
  plugins+=(archlinux systemadmin)
fi
plugins+=(you-should-use fzf-tab zsh-autosuggestions zsh-syntax-highlighting)
YSU_MESSAGE_POSITION="after"   # 有别名可用时，在命令输出后提示

# Catppuccin Mocha 语法高亮配色（须在 zsh-syntax-highlighting 加载前；浅色时用插件默认的终端色）
[[ $_theme == dark && -f "$HOME/.bin/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" ]] && source "$HOME/.bin/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh"

source "$ZSH/oh-my-zsh.sh"

# carapace：为上千个命令补全参数并显示说明（初始化脚本缓存，不拖慢启动）
if (( $+commands[carapace] )); then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  _carapace_init="${XDG_CACHE_HOME:-$HOME/.cache}/carapace/init.zsh"
  if [[ ! -s $_carapace_init || $commands[carapace] -nt $_carapace_init ]]; then
    mkdir -p "${_carapace_init:h}" && carapace _carapace zsh >| "$_carapace_init"
  fi
  source "$_carapace_init"
  compdef _git git            # git 保留 zsh 自带的补全（更完整）
  unset _carapace_init
fi

# -- history -------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY

# -- options -------------------------------------------------------------------
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS
unsetopt CORRECT_ALL

# -- environment ---------------------------------------------------------------
export EDITOR='nvim' VISUAL='nvim'
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export WORK="$HOME/work"
export GOPATH="$WORK/go"
export BINSCRIPT="$HOME/.bin"
export PYTHONUSERBASE="$HOME/.local"
export npm_config_prefix="$HOME/.local/lib/node_modules"
export CHEAT_COLORS=true
export CHEAT_USER_DIR="$HOME/.mycheat"
export NVIM_TUI_ENABLE_TRUE_COLOR=1
# 统一配色：Catppuccin Mocha（bat / delta / eza / lazygit / fzf）
export BAT_THEME_DARK="Catppuccin Mocha" BAT_THEME_LIGHT="Catppuccin Latte"   # bat ≥ 0.25 自动检测终端深浅色
export EZA_CONFIG_DIR="$HOME/.config/eza"
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"
export LESS='-R -F -i -M'
(( $+commands[bat] )) && export MANPAGER="sh -c 'col -bx | bat -l man -p'" MANROFFOPT="-c"

typeset -U path fpath
path=(
  "$HOME/.local/bin"
  "$HOME/.local/lib/node_modules/bin"
  "$HOME/.cargo/bin"
  "$BINSCRIPT"
  "$GOPATH/bin"
  $path
)

# -- aliases -------------------------------------------------------------------
alias grep='grep --color=auto'
alias vim='nvim' vi='nvim'           # 默认用 nvim（LazyVim）；原版 vim 用 \\vim 或 command vim
alias t='tmux new -A -s main'        # 有 main 会话就接入，没有就新建
alias ts='tmux-sessionizer'          # fzf 选项目目录 → 打开对应 tmux 会话
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lh --git --group-directories-first --icons=auto'
  alias la='eza -lah --git --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
fi
(( $+commands[bat] ))        && alias ccat='bat'
(( $+commands[prettyping] )) && alias pping='prettyping --nolegend'
(( $+commands[ncdu] ))       && alias ndu="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
(( $+commands[tldr] ))       && alias help='tldr'
(( $+commands[howdoi] ))     && h() { howdoi "$*" -c -n 5; }
(( $+commands[lazygit] ))    && alias lg='lazygit'
alias reload='exec zsh'
alias path='print -l $path'
alias cheat='bat -pp --language=md ~/.cheatsheet.md 2>/dev/null || cat ~/.cheatsheet.md'

nman() { vim -c "Nman $*" || echo "No manual entry for $*"; }
prev() { local PREV=$(fc -lrn | head -n 1); sh -c "pet new $(printf %q "$PREV")"; }
mkcd() { mkdir -p "$1" && cd "$1"; }
# thefuck：命令打错后输入 fuck 自动修正（首次调用才加载，不影响启动速度）
(( $+commands[thefuck] )) && fuck() { unfunction fuck; eval "$(thefuck --alias)"; fuck "$@"; }

# -- fzf -----------------------------------------------------------------------
if (( $+commands[fzf] )); then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    _fzf_compgen_path() { fd --hidden --follow --exclude .git . "$1"; }
    _fzf_compgen_dir()  { fd --type d --hidden --follow --exclude .git . "$1"; }
  fi
  export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border=rounded --info=inline-right
    --prompt='❯ ' --pointer='▶' --marker='✓' --separator='─' --scrollbar='│'
    $( [[ $_theme == light ]] \
      && echo '--color=bg+:#ccd0da,bg:-1,spinner:#dc8a78,hl:#d20f39,fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78
               --color=marker:#7287fd,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39,selected-bg:#bcc0cc,border:#9ca0b0,label:#4c4f69' \
      || echo '--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
               --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8,selected-bg:#45475a,border:#585b70,label:#cdd6f4' )"
  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :300 {} 2>/dev/null || eza --tree --level=2 --color=always {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} | head -100'"
  [[ -n $TMUX ]] && export FZF_TMUX=1 FZF_TMUX_OPTS='-p 80%,60%'   # tmux 里用浮动窗口
fi
[[ -f "$BINSCRIPT/zsh/fzf_custom.zsh" ]] && source "$BINSCRIPT/zsh/fzf_custom.zsh"

# fzf-tab：Tab 补全时用 fzf 并预览
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:(cd|z|pushd|eza|ls):*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
zstyle ':fzf-tab:complete:(vim|nvim|bat|cat|less):*' fzf-preview 'bat --color=always --line-range :100 $realpath 2>/dev/null || eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o command='
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
[[ -n $TMUX ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# -- tools ---------------------------------------------------------------------
(( $+commands[zoxide] ))   && eval "$(zoxide init zsh)"     # z <dir> 智能跳转, zi 交互选择
(( $+commands[starship] )) && eval "$(starship init zsh)"

# yazi 文件管理器：y 打开，退出后 shell 跳到最后浏览的目录
y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# -- key bindings --------------------------------------------------------------
autoload -U up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search; zle -N down-line-or-beginning-search; zle -N edit-command-line
for m in viins vicmd; do
  bindkey -M $m '^P' up-line-or-beginning-search      # 按已输入前缀搜索历史
  bindkey -M $m '^N' down-line-or-beginning-search
  bindkey -M $m '^[[A' up-line-or-beginning-search    # ↑ ↓ 同上
  bindkey -M $m '^[[B' down-line-or-beginning-search
  bindkey -M $m '^X^E' edit-command-line              # 在 vim 里编辑当前命令
done
bindkey -M viins '^@' autosuggest-accept              # Ctrl-Space 接受整条建议
bindkey -M viins '^F' forward-word                    # Ctrl-F 接受建议的一个词
bindkey -M viins '^[.' insert-last-word               # Alt-. 插入上条命令最后一个参数
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^[l' clear-screen                   # Alt-l 清屏（C-l 已用于 tmux 切 pane）
bindkey -M vicmd '^[l' clear-screen
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=(forward-word)

# atuin：Ctrl-r 全屏历史搜索（带目录 / 耗时 / 退出码），↑ 保持前缀搜索
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

# fzf-git：Ctrl-g 再按 f 文件 / b 分支 / h 提交 / s stash / t tag / r 远端 / l reflog / w worktree / ? 帮助
[[ -f "$HOME/.local/share/fzf-git.sh/fzf-git.sh" ]] && source "$HOME/.local/share/fzf-git.sh/fzf-git.sh"

# -- Android -------------------------------------------------------------------
if [[ $OSTYPE == darwin* ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
else
  export ANDROID_HOME="$WORK/Android/Sdk"
fi
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk-bundle" ANDROID_NDK="$ANDROID_HOME/ndk-bundle"
path=("$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator" $path)

# -- Linux / Arch --------------------------------------------------------------
if [[ $OSTYPE == linux* ]]; then
  alias diff='diff --color=auto' ip='ip -color=auto' dmesg='dmesg --color=always'
  (( $+commands[ruby] )) && export GEM_HOME="$HOME/.gem" && path=("$(ruby -e 'print Gem.user_dir')/bin" $path)
  [[ -f "$BINSCRIPT/zsh/pacman_cmd.zsh" ]] && (( $+commands[pacman] )) && source "$BINSCRIPT/zsh/pacman_cmd.zsh"
  # tty1 自动 startx，tty2 自动 sway
  if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx
  elif [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
    export XDG_SESSION_TYPE=wayland GDK_BACKEND=wayland CLUTTER_BACKEND=wayland SDL_VIDEODRIVER=wayland
    XKB_DEFAULT_LAYOUT=us exec sway
  fi
fi

# 本机私有配置
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# 输入法：vi 模式按 Esc 进入普通模式时自动切到英文（macism，brew install laishulu/homebrew/macism）
if (( $+commands[macism] )); then
  _ime_to_english() { [[ $KEYMAP == vicmd ]] && { macism com.apple.keylayout.USExtended >/dev/null 2>&1 &! } }
  autoload -Uz add-zle-hook-widget && add-zle-hook-widget zle-keymap-select _ime_to_english
fi
