#!/bin/bash

# shellcheck source=./logger.sh
source "$PWD/logger.sh"

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
        mv "${src_file}" "$dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
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
    bak_file ~ .ssh "${bakdir}"
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

install_all_package() {
    info "install arch package"
    sudo pacman -S --needed $(cat "$PWD/.arch-pkglist-official")
    pikaur -S $(cat "$PWD/.arch-pkglist-local" | grep -vx "$(pacman -Qqm)")
    info "install pip package"
    pip install --user -r "$PWD/.requirements.txt"
    cat $PWD/.vscode-extensions.txt | xargs -L 1 code --install-extension
    xargs npm install --global <"$PWD/.npm_package"
}

install_dotfile() {
    bak_config

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
    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh && cp "$PWD/.sshconfig" ~/.ssh/config
    info "dotfile:ssh config install successfully!"

    ### ideavim
    cp "$PWD/.ideavimrc" ~/.ideavimrc
    info "dotfile:ideavimrc install successfully!"

    ### gdbinit
    if curl git.io/.gdbinit -o ~/.gdbinit --progress; then
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
    curl https://cht.sh/:cht.sh -o ~/.bin/cht.sh/cht --progress
    chmod u+x ~/.bin/cht.sh/cht
    info "dotfile:cheat.sh install successfully!"

    #切换到zsh
    if sudo chsh -s /bin/zsh; then
        info "change zsh successfully!"
    else
        error "change zsh failed!"
    fi

    # vim
    if git clone https://github.com/leihuxi/vimrc.git ~/.vim_runtime; then
        sh ~/.vim_runtime/install_awesome_vimrc.sh
        info "dotifile:vimrc install successfully!"
    else
        error "dotfile:vimrc install failed!"
    fi
    info "all installed successfully, Please reboot your shell!"
}

update_software() {
    info "update zsh"
    (cd ~/.oh-my-zsh && git pull)
    info "update zsh-autosuggestions"
    (cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull)
    info "update zsh-syntax-highlighting"
    (cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull)
    info "update mysql-colorize"
    (cd ~/.oh-my-zsh/custom/plugins/mysql-colorize && git pull)
    info "update tmp"
    (cd ~/.tmux/plugins/tpm && git pull)
    info "update gdb"
    (bak_file ~ .gdbinit ~/.bakconfig && curl git.io/.gdbinit -o ~/.gdbinit --progress)
    info "update cht.sh"
    curl https://cht.sh/:cht.sh -o ~/.bin/cht.sh/cht --progress
    info "update .bin && .mycheat"
    cp -rf .bin ~
    cp -rf .mycheat ~
    info "update vscode && pacman"
    info "update official pkg list"
    pacman -Qqe | grep -vx "$(pacman -Qqg base)" | grep -vx "$(pacman -Qqm)" >"$PWD/.arch-pkglist-official"
    info "update local pkg list"
    pacman -Qqm >"$PWD/.arch-pkglist-local"
    info "update code "
    code --list-extensions >"$PWD/.vscode-extensions.txt"
    info "update pip package"
    pip freeze >"$PWD/.requirements.txt"
    info "update npm package"
    npm list --global --parseable --depth=0 | sed '1d' | awk -F'/' '{print $NF }' > "$PWD/.npm_package"
}

main() {
    if [[ "$1" == "up" ]]; then
        update_software
        exit
    fi
    install_all_package
    # install_dotfile
}

main $1
