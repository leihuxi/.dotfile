# fzf helpers — from leihuxi/.dotfile, cleaned up for macOS / zsh
# (fd 工具改由 fd 命令本身提供；原来的 fd() 改名为 fcd)

# fe [PATTERN] - 选文件用编辑器打开
fe() {
  local files
  files=(${(f)"$(fzf --query="$1" --multi --select-1 --exit-0 \
    --preview 'bat -n --color=always --line-range :300 {}')"})
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# vg [PATTERN] - ripgrep 搜内容，选中后跳到对应行
vg() {
  local sel
  sel=$(rg --line-number --no-heading --color=always --smart-case "${@:-.}" |
    fzf --ansi --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'right,60%,+{2}+3/3') || return
  ${EDITOR:-vim} "${sel%%:*}" +"$(cut -d: -f2 <<< "$sel")"
}

# fcd - cd 到子目录（含隐藏目录）
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git . "${1:-.}" | fzf +m \
    --preview 'eza --tree --level=2 --color=always {}') && cd "$dir"
}

# fdr - cd 到某个上级目录
fdr() {
  local d=${1:-$PWD} dirs=()
  while [[ $d != / ]]; do dirs+=("$d"); d=${d:h}; done
  dirs+=(/)
  local dir=$(print -l $dirs | fzf --tac) && cd "$dir"
}

# fh - 从历史选命令放到命令行（可编辑后回车）
fh() {
  print -z -- "$(fc -lnr 1 | awk '!seen[$0]++' | fzf +s)"
}

# sfc - 搜索文件内容
sfc() { rg --no-heading --color=always . | fzf --ansi; }

# fkill [SIGNAL] - 选进程杀掉
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --header='选择要结束的进程' | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -${1:-9}
}

### git
# fbr - 切换分支（按最近提交排序）
fbr() {
  local branch
  branch=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)' |
    fzf +m --preview 'git log --oneline --graph --color=always -20 {}') &&
    git checkout "$branch"
}

# fco - 切换分支 / tag（含远程）
fco() {
  local target
  target=$(
    { git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'
      git branch --all | grep -v HEAD | sed 's/.* //; s#remotes/[^/]*/##' | sort -u |
        awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}'; } |
    fzf --ansi +m -d '\t' -n 2 \
      --preview 'git log --oneline --color=always -50 HEAD..{2}') || return
  git checkout "$(awk '{print $2}' <<< "$target")"
}

# fshow - 提交浏览器，回车查看详情
fshow() {
  git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs git show --color=always | delta' \
      --bind 'enter:execute(grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs git show --color=always | less -R)'
}

# fcs - 选一个 commit 输出其 sha，例如 git rebase -i $(fcs)
fcs() {
  git log --color=always --pretty=oneline --abbrev-commit |
    fzf +s +m --ansi --preview 'git show --color=always {1} | delta' | awk '{print $1}'
}

# fstash - enter 查看, ctrl-d 与 HEAD 对比, ctrl-b 检出为分支
fstash() {
  local out q k sha
  while out=$(git stash list --pretty='%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs' |
      fzf --ansi --no-sort --query="$q" --print-query --expect=ctrl-d,ctrl-b); do
    local lines=(${(f)out})
    q=${lines[1]} k=${lines[2]} sha=${${lines[-1]}%% *}
    [[ -z "$sha" ]] && continue
    case $k in
      ctrl-d) git diff "$sha" ;;
      ctrl-b) git stash branch "stash-$sha" "$sha"; break ;;
      *)      git stash show -p "$sha" ;;
    esac
  done
}

### tmux
# tm [NAME] - 进入/新建会话；无参数时 fzf 选择
tm() {
  local change=attach-session session
  [[ -n "$TMUX" ]] && change=switch-client
  if [[ -n $1 ]]; then
    tmux $change -t "$1" 2>/dev/null || { tmux new-session -d -s "$1" && tmux $change -t "$1"; }
    return
  fi
  session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --exit-0) &&
    tmux $change -t "$session" || echo "No sessions found."
}

# ftpane - 跳转到任意 pane
ftpane() {
  local target
  target=$(tmux list-panes -a -F '#S:#I.#P  #{pane_current_command}  #{pane_current_path}' |
    fzf +m --preview 'tmux capture-pane -ep -t {1}') || return
  target=${target%% *}
  tmux switch-client -t "${target%%.*}" 2>/dev/null
  tmux select-window -t "${target%.*}" && tmux select-pane -t "$target"
}

### Chrome 历史
c() {
  local cols=$(( COLUMNS / 3 )) sep='{::}' tmp=$(mktemp)
  local hist="$HOME/Library/Application Support/Google/Chrome/Default/History" open=open
  if [[ $OSTYPE == linux* ]]; then
    hist="$HOME/.config/chromium/Default/History" open=xdg-open
    [[ -f $hist ]] || hist="$HOME/.config/google-chrome/Default/History"
  fi
  cp -f "$hist" "$tmp" || return
  sqlite3 -separator $sep "$tmp" "select substr(title, 1, $cols), url from urls order by last_visit_time desc" |
    awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
    fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open >/dev/null 2>&1
  rm -f "$tmp"
}

# v - 打开 vim 最近编辑过的文件
v() {
  local files
  files=$(grep '^>' ~/.viminfo 2>/dev/null | cut -c3- | while read -r line; do
    [[ -f "${line/\~/$HOME}" ]] && echo "$line"; done | fzf -m -q "$*" -1) &&
    vim ${(f)files//\~/$HOME}
}
