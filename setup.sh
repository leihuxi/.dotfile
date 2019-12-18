#!/bin/bash

# shellcheck source=./logger.sh
source "$PWD/logger.sh"
# 设置包的安装目录
export npm_config_prefix="~/.local/lib/node_modules"
export PYTHONUSERBASE="~/.local"
export GEM_HOME="~/.gem"
export GOPATH="~/work/go"

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    echo "you hit Ctrl-C/Ctrl-\, now exiting.."
}

is_arch_base_system() {
    command -v pacman > /dev/null 2>&1 && echo "arch"
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
    bakdir=~/.bakconfig
    [ -d "${bakdir}" ] || mkdir "${bakdir}"
    bak_file ~ .zshrc "${bakdir}"
    bak_file ~ .tmux.conf "${bakdir}"
    bak_file ~ .tmux "${bakdir}"
    bak_file ~ .gdbinit "${bakdir}"
    bak_file ~ .oh-my-zsh "${bakdir}"
    bak_file ~/.ssh config "${bakdir}"
    bak_file ~/.config/alacritty alacritty.yml "${bakdir}"
    bak_file ~ .xprofile "${bakdir}"
    bak_file ~ .xinitrc "${bakdir}"
    bak_file ~ .Xresources "${bakdir}"
    bak_file ~ .gitconfig "${bakdir}"
    bak_file ~ .clang-format "${bakdir}"
    bak_file ~ .bin "${bakdir}"
    bak_file ~ .vim_runtime "${bakdir}"
    bak_file ~ .vimrc "${bakdir}"
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
    if git clone https://github.com/gpakosz/.tmux.git ~/.tmux; then
        ln -s -f .tmux/.tmux.conf ~/.tmux.conf
        cp "$PWD/.tmux.conf.local" ~
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        info "dotfile:tmux.conf install successfully!"
    else
        error "dotfile:zshrc install failed"
    fi

    ### ssh
    if [[ ! -d ~/.ssh ]]; then
        mkdir -p ~/.ssh
    fi
    cp "$PWD/.ssh/config" ~/.ssh/config
    info "dotfile:ssh config install successfully!"

    ### ideavim
    cp "$PWD/.ideavimrc" ~/.ideavimrc
    info "dotfile:ideavimrc install successfully!"

    ### gdbinit
    if curl -o ~/.gdbinit -O -L -C - git.io/.gdbinit; then
        info "dotfile:gdbinit install successfully!"
    else
        info "dotfile:gdbinit install failed!"
    fi

    ## oh-my-zsh
    if git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh; then
        cp "$PWD"/.zshrc ~
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        git clone https://github.com/horosgrisa/mysql-colorize ~/.oh-my-zsh/custom/plugins/mysql-colorize
        git clone https://github.com/denisidoro/navi ~/.oh-my-zsh/custom/plugins/navi
        info "dotfile:zshrc install successfully!"
    else
        error "dotfile:zshrc install failed!"
    fi

    ## bin
    cp -rf "$PWD/.bin" ~
    cp -rf "$PWD/.mycheat" ~

    ##git
    cp "$PWD/.gitconfig" ~

    #Xconfig
    cp "$PWD/.xprofile" ~
    cp "$PWD/.Xresources" ~
    cp "$PWD/.xinitrc" ~
    cp -rf "$PWD/.config" ~
    info "dotfile:xconfig install successfully!"

    ##clang-format
    cp "$PWD/.clang-format" ~

    #cheat.sh
    curl -o ~/.bin/cht.sh/cht -O -L -C - https://cht.sh/:cht.sh --progress
    chmod u+x ~/.bin/cht.sh/cht
    info "dotfile:cheat.sh install successfully!"

    #切换到zsh
    if sudo chsh -s /bin/zsh; then
        info "change zsh successfully!"
    else
        error "change zsh failed!"
    fi

    # vim
    info "vim: may take long time...., Ctrl+C to install manualy"
    if $(is_install vim) && git clone https://github.com/leihuxi/vimrc.git ~/.vim_runtime; then
        sh ~/.vim_runtime/install_awesome_vimrc.sh
        info "dotifile:vimrc install successfully!"
    else
        error "dotfile:vimrc install failed!"
    fi
    info "all installed successfully, Please reboot your shell!"
}

install_pkg() {
    arch=$(is_arch_base_system)
    if [[ $arch != "arch" ]]; then
        return;
    fi
    info "install arch package"
    sudo pacman -S --needed - <"$PWD/.arch-pkglist-official"
}

install_third_pkg() {
    arch=$(is_arch_base_system)
    if [[ $arch != "arch" ]]; then
        return;
    fi

    rm -rf /tmp/yay
    if git clone https://aur.archlinux.org/yay.git /tmp/yay; then
        (cd /tmp/yay && makepkg -si)
    fi

    yay -S $(cat "$PWD/.arch-pkglist-local" | grep -vx "$(pacman -Qqm)")
    info "install pip package"
    pip install --ignore-installed --upgrade --user -r "$PWD/.requirements.txt"
    cat $PWD/.vscode-extensions.txt | xargs -L 1 code --install-extension
    xargs npm install --global <"$PWD/.npm_package"
}

update_third_pkg() {
    arch=$(is_arch_base_system)
    if [[ $arch != "arch" ]]; then
        return;
    fi

    info "update local pkg list"
    pacman -Qqm >"$PWD/.arch-pkglist-local"
    info "update pip package"
    pip freeze | sed 's/=.*//' >"$PWD/.requirements.txt"
    info "update npm package"
    npm list --global --parseable --depth=0 | sed '1d' | awk -F'/' '{print $NF }' >"$PWD/.npm_package"
}

update_pkg() {
    info "update zsh"
    (cd ~/.oh-my-zsh && git pull)
    info "update zsh-autosuggestions"
    (cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull)
    info "update zsh-syntax-highlighting"
    (cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull)
    info "update mysql-colorize"
    (cd ~/.oh-my-zsh/custom/plugins/mysql-colorize && git pull)
    info "update navi"
    (cd ~/.oh-my-zsh/custom/plugins/navi && git pull)
    info "update tmp"
    (cd ~/.tmux/plugins/tpm && git pull)
    info "update gdb"
    (bak_file ~ .gdbinit ~/.bakconfig && curl -o ~/.gdbinit -O -L -C - git.io/.gdbinit --progress)
    info "update cht.sh"
    curl -o ~/.bin/cht.sh/cht -O -L -C - https://cht.sh/:cht.sh --progress
    info "update .bin && .mycheat"
    cp -rf .bin ~
    cp -rf .mycheat ~
    info "export official pkg list"
    pacman -Qqe | grep -vx "$(pacman -Qqg base)" | grep -vx "$(pacman -Qqm)" >"$PWD/.arch-pkglist-official"
    info "export vscode "
    code --list-extensions >"$PWD/.vscode-extensions.txt"
}

main() {
    if [[ "$1" == "install" ]]; then
        install_pkg
        install_dotfile
        exit
    fi
    update_pkg
    update_third_pkg
}

main $1
