#!/bin/bash

# shellcheck source=./logger.sh
source "$PWD/logger.sh"
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
    if [ -f "${src_file}" ] || [ -d "${src_file}" ]; then
        info "bak ${src_file} to $dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
        if [[ -L "${src_file}" ]]; then
            cp -l "${src_file}" "$dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
            unlink "${src_file}"
        else
            mv "${src_file}" "$dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
        fi
    fi
}

bak_config() {
    bakdir=$HOME/.bakconfig
    [ -d "${bakdir}" ] || mkdir "${bakdir}"
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

install_dotfile() {
    bak_config

    ## polybar
    rm -rf /tmp/polybar
    if git clone https://github.com/polybar/polybar.git /tmp/polybar; then
        (cd /tmp/polybar && ./build.sh)
    fi

    ### tmux
    if git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"; then
        ln -s -f .tmux/.tmux.conf $HOME/.tmux.conf
        cp "$PWD/.tmux.conf.local" $HOME
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
    bak_file $HOME .vim_runtime "${bakdir}"
    bak_file $HOME .vimrc "${bakdir}"
    # vim
    info "vim: may take long time...., Ctrl+C to install manualy"
    if $(is_install vim) && git clone https://github.com/leihuxi/vimrc.git $HOME/.vim_runtime; then
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
    yay -S $(cat "$PWD/.arch-pkglist-local" | grep -vx "$(pacman -Qqm)")

    info "install vscode package"
    cat $PWD/.vscode-extensions.txt | xargs -L 1 code --install-extension

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
}

update_third_pkg() {
    info "update local pkg list"
    pacman -Qqm >"$PWD/.arch-pkglist-local"
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
    pacman -Qqe | grep -vx "$(pacman -Qqm)" >"$PWD/.arch-pkglist-official"
    info "export vscode "
    code --list-extensions >"$PWD/.vscode-extensions.txt"
}

main() {
    arch=$(is_arch_base_system)
    if [[ $arch != "arch" ]]; then
        echo "archlinux support only"
        exit
    fi

    if [[ "$1" == "install" ]]; then
        install_pkg
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
    else
        update_pkg
        update_third_pkg
    fi
}

main $1
