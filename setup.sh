#!/bin/bash

# shellcheck source=./logger.sh
source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
# 设置包的安装目录
export npm_config_prefix="$HOME/.local/lib/node_modules"
export PYTHONUSERBASE="$HOME/.local"
export GEM_HOME="$HOME/.gem"
export GOPATH="$HOME/work/go"

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    echo "you hit Ctrl-C/Ctrl-\, now exiting.."
}

is_arch_base_system() {
    command -v pacman >/dev/null 2>&1 && echo "arch"
}

is_install() {
    while true; do
        read -p "Do you wish to install $1[Y/n]?" yn
        case $yn in
        [Yy]*)
            return 0
            ;;
        [Nn]*)
            return 1
            ;;
        *)
            return 0
            ;;
        esac
    done
}

is_sudo() {
    if sudo echo; then
        error "This script must be run by root or a sudo'er"
        exit 1
    fi
}

bak_file() {
    src_dir="$1"
    filename="$2"
    dst_dir="$3"
    src_file="${src_dir}/${filename}"
    if [[ -L "${src_file}" ]]; then
        unlink "${src_file}"
    elif [ -f "${src_file}" ] || [ -d "${src_file}" ]; then
        local dst="$dst_dir/${filename}_$(date +%Y%m%d%H%M%S)_dotfile"
        info "bak ${src_file} to ${dst}"
        mv "${src_file}" "${dst}"
    fi
}

bak_config() {
    bakdir=$HOME/.bakconfig
    [ -d "${bakdir}" ] || mkdir -p "${bakdir}"
    bak_file $HOME .zshrc "${bakdir}"
    bak_file $HOME .tmux.conf "${bakdir}"
    bak_file $HOME .tmux "${bakdir}"
    bak_file $HOME .gdbinit "${bakdir}"
    bak_file $HOME .oh-my-zsh "${bakdir}"
    bak_file $HOME/.ssh config "${bakdir}"
    bak_file $HOME/.config/alacritty alacritty.yml "${bakdir}"
    bak_file $HOME/.config/i3 "${bakdir}"
    bak_file $HOME .xprofile "${bakdir}"
    bak_file $HOME .xinitrc "${bakdir}"
    bak_file $HOME .Xresources "${bakdir}"
    bak_file $HOME .gitconfig "${bakdir}"
    bak_file $HOME .clang-format "${bakdir}"
    bak_file $HOME .bin "${bakdir}"
    info "bak all file successfully"
}

bak_etc() {
    bakdir=$HOME/.baketc
    [ -d "${bakdir}" ] || mkdir -p "${bakdir}"
    xargs -a <(sudo pacman -Qii | awk '/^MODIFIED/ {print $2}') sudo cp --parent -t ${bakdir}
}

install_from_source() {
    if  git clone https://github.com/powerline/fonts.git; then
        (cd ~/.fonts && install.sh)
    fi

    rm -rf /tmp/alacritty
    if git clone https://github.com/jwilm/alacritty.git /tmp/alacritty; then
        (
            rustup override set stable && rustup update stable
            cd /tmp/alacritty && cargo build --release
            sudo cp -f target/release/alacritty /usr/local/bin # or anywhere else in $PATH
            sudo cp -f extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
            sudo desktop-file-install extra/linux/Alacritty.desktop
            sudo update-desktop-database

            sudo mkdir -p /usr/local/share/man/man1
            gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
        )
        info "dotfile:alacrittyinstall successfully!"
    fi

    rm -rf /tmp/polybar
    if git clone https://github.com/polybar/polybar.git /tmp/polybar; then
        (cd /tmp/polybar && ./build.sh)
        info "dotfile:polybar install successfully!"
    fi
}

install_dotfile() {
    bak_config

    install_from_source

    ### tmux
    if git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"; then
        mkdir -p $HOME/.resurrect/
        ln -s -f .tmux/.tmux.conf $HOME/.tmux.conf
        cp "$PWD/.tmux.conf.local" $HOME
        cp "$PWD/.cheatsheet.md" $HOME
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        info "dotfile:tmux.conf install successfully!"
    else
        error "dotfile:zshrc install failed"
    fi

    ### ssh
    if [[ ! -d $HOME/.ssh ]]; then
        mkdir -p $HOME/.ssh
    fi
    cp "$PWD/.ssh/config" $HOME/.ssh/config
    info "dotfile:ssh config install successfully!"

    ### ideavim
    cp "$PWD/.ideavimrc" $HOME/.ideavimrc
    info "dotfile:ideavimrc install successfully!"

    ### gdbinit
    if curl -o $HOME/.gdbinit -O -L -C - git.io/.gdbinit; then
        info "dotfile:gdbinit install successfully!"
    else
        info "dotfile:gdbinit install failed!"
    fi

    ## oh-my-zsh
    if git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh; then
        cp "$PWD"/.zshrc "$HOME"
        git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        git clone https://github.com/Aloxaf/fzf-tab $HOME/.oh-my-zsh/custom/plugins/fzf-tab
        git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
        git clone https://github.com/horosgrisa/mysql-colorize $HOME/.oh-my-zsh/custom/plugins/mysql-colorize
        git clone https://github.com/denisidoro/navi $HOME/.oh-my-zsh/custom/plugins/navi
        info "dotfile:zshrc install successfully!"
    else
        error "dotfile:zshrc install failed!"
    fi

    ## bin
    cp -rf "$PWD/.bin" $HOME
    cp -rf "$PWD/.mycheat" $HOME

    ##git
    cp "$PWD/.gitconfig" $HOME

    #Xconfig
    cp "$PWD/.xprofile" $HOME
    cp "$PWD/.Xresources" $HOME
    cp "$PWD/.xinitrc" $HOME
    cp -rf "$PWD/.config" $HOME
    info "dotfile:xconfig install successfully!"

    ##clang-format
    cp "$PWD/.clang-format" $HOME

    #cheat.sh
    curl https://cht.sh/:cht.sh >$HOME/.bin/cht.sh/cht
    chmod u+x $HOME/.bin/cht.sh/cht
    info "dotfile:cheat.sh install successfully!"

    #切换到zsh
    if sudo chsh -s /bin/zsh; then
        info "change zsh successfully!"
    else
        error "change zsh failed!"
    fi
    info "all installed successfully, Please reboot your shell!"
}

install_vim() {
    bakdir=$HOME/.bakconfig
    [ -d "${bakdir}" ] || mkdir "${bakdir}"
    # vim
    info "vim: may take long time...., Ctrl+C to install manualy"
    if [[ -d "$HOME/.vim_runtime/.git" ]]; then
        git -C "$HOME/.vim_runtime" pull --ff-only -q || warning "vimrc: pull failed, keep local version"
        sh $HOME/.vim_runtime/install_awesome_vimrc.sh
        info "dotifile:vimrc update successfully!"
        return
    fi
    bak_file $HOME .vim_runtime "${bakdir}"
    bak_file $HOME .vimrc "${bakdir}"
    if is_install vim && git clone https://github.com/leihuxi/vimrc.git $HOME/.vim_runtime; then
        sh $HOME/.vim_runtime/install_awesome_vimrc.sh
        info "dotifile:vimrc install successfully!"
    else
        error "dotfile:vimrc install failed!"
    fi
}

install_pkg() {
    info "install arch package"
    sudo pacman -S --needed - <"$PWD/.arch-pkglist-official"
}

install_third_pkg() {
    rm -rf /tmp/yay
    if git clone https://aur.archlinux.org/yay.git /tmp/yay; then
        (cd /tmp/yay && makepkg -si)
    fi

    info "install yay package"
    # yay -S $(cat "$PWD/.arch-pkglist-local")
    for i in $(cat ./.arch-pkglist-local ); do info "install $i"; yay -S $i; done

    info "install npm package"
    for npm_pkg in $(cat "$PWD/.npm_package" | sed '1d' | awk -F'/' '{print $NF}'); do
        npm install --global $npm_pkg
    done

    info "install cargo package"
    for cargo_pkg in $(cat "$PWD/.cargo_package" | grep ':' | awk '{print $1}'); do
        cargo install $cargo_pkg
    done

    info "install gem package"
    for gem_pkg in $(cat "$PWD/.gem_package" | grep -v '*' | awk '{print $1}'); do
        gem install $gem_pkg
    done

    info "install pip package"
    for pip_pkg in $(cat "$PWD/.requirements.txt" | sed 's/=.*//'); do
        pip install --ignore-installed --upgrade --user $pip_pkg
    done

    info "install vscode package"
    cat $PWD/.vscode-extensions.txt | xargs -L 1 code --install-extension
}

update_third_pkg() {
    info "update local pkg list"
    pacman -Qqm > "$PWD/.arch-pkglist-local"
    info "update pip package"
    pip freeze > "$PWD/.requirements.txt"
    info "update npm package"
    npm list --global --parseable --depth=0 >"$PWD/.npm_package"
    info "update gem package"
    gem list --local > "$PWD/.gem_package"
    info "update cargo package"
	cargo install --list > "$PWD/.cargo_package"
}

update_pkg() {

    info "update zsh"
    (cd $HOME/.oh-my-zsh && git pull)
    info "update zsh-autosuggestions"
    (cd $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull)
    info "update zsh-syntax-highlighting"
    (cd $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull)
    info "update mysql-colorize"
    (cd $HOME/.oh-my-zsh/custom/plugins/mysql-colorize && git pull)
    info "update navi"
    (cd $HOME/.oh-my-zsh/custom/plugins/navi && git pull)
    info "update tmp"
    (cd $HOME/.tmux/plugins/tpm && git pull)
    info "update gdb"
    (bak_file $HOME .gdbinit $HOME/.bakconfig && curl -o $HOME/.gdbinit -O -L -C - git.io/.gdbinit)
    info "update cht.sh"
    curl https://cht.sh/:cht.sh >$HOME/.bin/cht.sh/cht
    info "update .bin && .mycheat"
    cp -rf .bin $HOME
    cp -rf .mycheat $HOME
    info "export official pkg list"
    pacman -Qqn >"$PWD/.arch-pkglist-official"
    info "export vscode "
    code --list-extensions >"$PWD/.vscode-extensions.txt"
}

######################################################################
# macOS
######################################################################
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

# 把仓库里的文件链接到 $HOME（已有文件先备份到 ~/.bakconfig）
link_file() {
    local src="$DOTFILE/$1" dst="$HOME/${2:-$1}"
    if [[ "$(readlink "$dst")" == "$src" ]]; then
        return
    fi
    mkdir -p "$(dirname "$dst")"
    bak_file "$(dirname "$dst")" "$(basename "$dst")" "$HOME/.bakconfig"
    ln -s "$src" "$dst"
    info "link $dst -> $src"
}

git_clone_or_pull() {
    if [[ -d "$2/.git" ]]; then
        git -C "$2" pull --ff-only -q
    else
        git clone --depth 1 -q "$1" "$2"
    fi
}

# tmux-thumbs 官方只有 Intel Mac 预编译包，这里用 brew 的 rust 本地编译（tpm 会把已存在的目录视为已安装）
install_tmux_extras() {
    local dir="$HOME/.config/tmux/plugins/tmux-thumbs"
    git_clone_or_pull https://github.com/fcsonline/tmux-thumbs "$dir"
    if command -v cargo >/dev/null; then
        (cd "$dir" && cargo build --release -q) && info "dotfile:tmux-thumbs build successfully!" ||
            warning "tmux-thumbs: cargo build failed"
    else
        warning "tmux-thumbs: cargo not found (brew install rust)"
    fi
}

# Claude Code × tmux：状态栏用量（ccusage）+ Claude 等你时窗口标签显示 󰚩（hooks）
install_claude_tmux() {
    npm install --global ccusage@latest || warning "ccusage install failed"
    local settings="$HOME/.claude/settings.json" notify="~/.bin/claude-tmux-notify"
    mkdir -p "$HOME/.claude"
    [[ -s "$settings" ]] || echo '{}' >"$settings"
    if jq -e --arg n "$notify" '[.hooks[]?[]?.hooks[]?.command] | any(startswith($n))' "$settings" >/dev/null; then
        return
    fi
    cp "$settings" "$settings.bak"
    jq --arg n "$notify" '
        def add(ev; arg): .hooks[ev] = ((.hooks[ev] // []) + [{hooks: [{type: "command", command: "\($n) \(arg)", timeout: 5}]}]);
        add("Stop"; "wait") | add("Notification"; "wait") | add("UserPromptSubmit"; "clear")
    ' "$settings.bak" >"$settings" && info "dotfile:claude tmux hooks install successfully!"
}

install_macos() {
    DOTFILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    mkdir -p "$HOME/.bakconfig"

    ### Homebrew + 软件
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew bundle --file "$DOTFILE/Brewfile"

    ### oh-my-zsh + 插件
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        git -C "$HOME/.oh-my-zsh" pull --ff-only -q
    fi
    local zc="$HOME/.oh-my-zsh/custom/plugins"
    git_clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$zc/zsh-autosuggestions"
    git_clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$zc/zsh-syntax-highlighting"
    git_clone_or_pull https://github.com/zsh-users/zsh-completions "$zc/zsh-completions"
    git_clone_or_pull https://github.com/Aloxaf/fzf-tab "$zc/fzf-tab"
    git_clone_or_pull https://github.com/MichaelAquilina/zsh-you-should-use "$zc/you-should-use"
    git_clone_or_pull https://github.com/junegunn/fzf-git.sh "$HOME/.local/share/fzf-git.sh"
    info "dotfile:oh-my-zsh install successfully!"

    ### oh-my-tmux（XDG 布局，插件由 oh-my-tmux 自动安装到 ~/.config/tmux/plugins）
    if [[ -d "$HOME/.local/share/oh-my-tmux/.git" ]]; then
        git -C "$HOME/.local/share/oh-my-tmux" pull --ff-only -q
    else
        git clone -q --single-branch https://github.com/gpakosz/.tmux.git "$HOME/.local/share/oh-my-tmux"
    fi
    mkdir -p "$HOME/.config/tmux"
    ln -sfn "$HOME/.local/share/oh-my-tmux/.tmux.conf" "$HOME/.config/tmux/tmux.conf"
    info "dotfile:oh-my-tmux install successfully!"

    ### 配置文件（软链接，修改后直接在仓库里提交）
    link_file .zshrc
    link_file .tmux.conf.local .config/tmux/tmux.conf.local
    link_file .gitconfig
    link_file .bin/zsh .bin/zsh
    link_file .bin/tmux-sessionizer
    link_file .bin/tmux-git-branch
    link_file .bin/claude-tmux-status
    link_file .bin/claude-tmux-notify
    link_file .bin/claude-format
    link_file .claude/settings.json
    link_file .gitignore_global
    link_file .mycheat
    link_file .cheatsheet.md
    link_file .ideavimrc
    link_file .clang-format
    link_file .config/ghostty/config
    link_file .config/starship.toml
    link_file .config/nvim
    link_file .config/eza
    link_file .config/lazygit
    link_file .config/atuin
    link_file .config/btop/btop.conf
    link_file .config/yazi
    (cd "$HOME/.config/yazi" && ya pkg install) || warning "yazi: flavor install failed"
    [[ -s "$HOME/.local/share/atuin/history.db" ]] || atuin import zsh
    info "dotfile:config link successfully!"

    install_tmux_extras
    install_claude_tmux

    ### vim（leihuxi/vimrc）
    install_vim

    [[ "$SHELL" == */zsh ]] || chsh -s /bin/zsh
    info "all installed successfully! 打开 Ghostty，输入 t 进入 tmux，cheat 查看快捷键"
}

main() {
    if is_macos; then
        case "$1" in
        vim) install_vim ;;
        *) install_macos ;;
        esac
        exit
    fi

    arch=$(is_arch_base_system)
    if [[ $arch != "arch" ]]; then
        echo "only macOS and archlinux are supported"
        exit
    fi

    if [[ "$1" == "install" ]]; then
        install_pkg
        install_third_pkg
        install_dotfile
        exit
    elif [[ "$1" == "dot" ]]; then
        install_dotfile
        exit
    elif [[ "$1" == "vim" ]]; then
        install_vim
        exit
    elif [[ "$1" == "third" ]]; then
        install_third_pkg
        exit
    elif [[ "$1" == "baketc" ]]; then
        bak_etc
        exit
    else
        update_pkg
        update_third_pkg
        install_from_source
    fi
}

main $1
