# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(archlinux wd zsh-autosuggestions zsh-syntax-highlighting colored-man-pages vi-mode)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
else
   export EDITOR='vim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#####user custom config##############
# export TERM=xterm-256color
export WORK=$HOME/work
export GOPATH=$HOME/work/go
export BINSCRIPT=$HOME/.bin
export PATH=$BINSCRIPT:$GOPATH/bin:$PATH
export CHEATCOLORS=true
#Neovim true color support
export NVIM_TUI_ENABLE_TRUE_COLOR=1
#Neovim cursor shape support
export NVIM_TUI_ENABLE_CURSOR_SHAPE=1
export PATH="$HOME/.local/lib/node_modules/bin:$PATH"
export npm_config_prefix=~/.local/lib/node_modules
export PYTHONUSERBASE="$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"
export GEM_HOME=$HOME/.gem
export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"
export ANDROID_HOME=$WORK/Android/Sdk
export ANDROID_NDK=$ANDROID_HOME/ndk-bundle
# Some programs such as gradle ask this as well:
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk-bundle
export PATH="$ANDROID_NDK:$PATH"

export CHEAT_COLORS=true
export CHEAT_USER_DIR="~/.mycheat"

alias diff='diff --color=auto'
alias dmesg='dmesg --color=always '
alias grep='grep --color=auto'

alias h='function hdi(){ howdoi "$*" -c -n 5; }; hdi'
alias t='tmux attach'
alias tip='taocl|cowsay|lolcat'
alias cht='~/.bin/cht.sh/cht'
alias checkrootkits="sudo rkhunter --update; sudo rkhunter --propupd; sudo rkhunter --check"
alias checkvirus="sudo clamscan --recursive=yes --infected /home"
alias updateantivirus="sudo freshclam"

alias ccat='bat'
alias pping='prettyping --nolegend'
alias ndu="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias help='tldr --linux -t base16'

alias ft='find . -type f | ag '

alias idea='$WORK/source/idea-IC-191.6183.87/bin/idea.sh'
alias studio='$WORK/source/android-studio/bin/studio.sh'

nman() {
    vim -c "Nman $*"

    if [ "$?" != "0" ]; then
        echo "No manual entry for $*"
    fi
}

function taocl() {
    curl -s https://raw.githubusercontent.com/jlevy/the-art-of-command-line/master/README.md |
        sed '/cowsay[.]png/d' |
        pandoc -f markdown -t html |
        xmlstarlet fo --html --dropdtd |
        xmlstarlet sel -t -v "(html/body/ul/li[count(p)>0])[$RANDOM mod last()+1]" |
        xmlstarlet unesc | fmt -80 | iconv -t US
}

function prev() {
    PREV=$(fc -lrn | head -n 1)
    sh -c "pet new `printf %q "$PREV"`"
}


set -o vi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source "$HOME/.bin/zsh/fzf_custom.zsh"
source "$HOME/.bin/zsh/pacman_cmd.zsh"

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    exec startx
elif [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
    XDG_SESSION_TYPE=wayland
    GDK_BACKEND=wayland
    CLUTTER_BACKEND=wayland
    SDL_VIDEODRIVER=wayland
    XKB_DEFAULT_LAYOUT=us exec sway
fi
