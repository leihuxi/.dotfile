#!/bin/bash

# shellcheck source=./logger.sh
source "$PWD/logger.sh"

is_sudo() {
    if sudo echo; then
        error "This script must be run by root or a sudo'er"
        exit 1
    fi
}

check_os_type() {
    case $(uname) in
    Linux)
        command -v yum && {
            echo "CentOS"
            return
        }
        command -v apt-get && {
            echo "Ubuntu"
            return
        }
        command -v pacman && {
            echo "Arch"
            return
        }
        ;;
    Darwin)
        echo "Mac"
        return
        ;;
    *)
        # Handle AmgiaOS, CPM, and modified cable modems here.
        ;;
    esac
}

program_already_installed() {
    if command -v "$@" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

install_program() {
    local os
    os=$(check_os_type)
    local program_name=$1
    info "you os is ${os}, install ${program_name}"
    if [ "$os" = "Ubuntu" ]; then
        sudo apt install ${program_name}
    elif [ "$os" = "Arch" ]; then
        sudo pacman -Sy ${program_name}
    elif [ "$os" = "Mac" ]; then
        brew list ${program_name} &>/dev/null || brew install ${program_name}
    elif [ "$os" = "CentOS" ]; then
        sudo yum install ${program_name}
    fi
    if [ $? -ne 0 ]; then
        error "${program_name} install failed!"
        exit 1
    fi
    info "${program_name} is install successfully!"
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

install_program_third_parted() {
    npm install -g taskbook
    npm install -g fx
    npm install -g arch-wiki-man
    pip install --user howdoi
    pip install --user gdbgui
    gem install tmuxinator
}

install_program_list_required() {
    applist_all_os=(global curl git vim zsh tmux wget cmake python shellcheck rlwrap)
    #fix ycm arch bug
    if [ "$(check_os_type)" = "Arch" ]; then
        applist_all_os+=(jq tldr prettyping bat fzf htop diff-so-fancy fd ncdu the_silver_searcher)
        applist_all_os+=(expac ncurses5-compat-libs ctags powerline-fonts go)
        applist_all_os+=(alacritty-git alacritty-terminfo-git)
        applist_all_os+=(flake8 yapf python-isort)
        applist_all_os+=(i3-gaps i3lock py3status compton rofi feh ranger alsa-utils xorg xorg-init scrot xrand arand dunst)
        applist_all_os+=(ltrace strace valgrind gdb pmap lsof task)
        # applist_all_os+=( arch-audit )
    fi

    if [ "$(check_os_type)" = "Ubuntu" ]; then
        applist_all_os+=(exuberant-ctags fonts-powerline silversearcher-ag golang)
    fi

    if [ "$(check_os_type)" = "CentOS" ]; then
        applist_all_os+=(ctags powerline-fonts the_silver_searcher golang)
    fi

    if [ "$(check_os_type)" != "Mac" ]; then
        applist_all_os+=(python-setuptools python-appdirs python-pyparsing python-setuptools python-six python-pip)
        # For tip
        # applist_all_os+=( xmlstarlet pandoc cowsay lolcat xsel )
        # For system
        # applist_all_os+=( sysdig sysstat)
        # For html js synatic
        # applist_all_os+=( eslint typescript alex )
        applist_all_os+=(bcc-git bcc-tools-git python-bcc-git)
        applist_all_os+=(arpwatch audit rkhunter progress lynis netdata)
        applist_all_os+=(xlockmore progress)

    fi
    install_program "${applist_all_os[*]}"
    if [ "$(check_os_type)" != "Arch" ]; then
        sudo pip install pep8 flake8 pyflakes isort yapf
    fi
}

bak_config() {
    bakdir=~/.bakconfig
    [ -d "${bakdir}" ] || mkdir "${bakdir}"
    bak_file ~ .vimrc "${bakdir}"
    bak_file ~ .zshrc "${bakdir}"
    bak_file ~ .tmux.conf "${bakdir}"
    bak_file ~ .tmux "${bakdir}"
    bak_file ~ .gdbinit "${bakdir}"
    bak_file ~ .oh-my-zsh "${bakdir}"
    bak_file ~ .vim_runtime "${bakdir}"
    bak_file ~ .ssh "${bakdir}"
    bak_file ~/.config/alacritty alacritty.yml "${bakdir}"
    bak_file ~ .fzf_custom.zsh "${bakdir}"
    bak_file ~ .xprofile "${bakdir}"
    bak_file ~ .xinitrc "${bakdir}"
    bak_file ~ .Xresources "${bakdir}"
    bak_file ~ .pacman_cmd.zsh "${bakdir}"
    bak_file ~ .cht.sh "${bakdir}"
    bak_file ~ .fzf-scripts "${bakdir}"
    bak_file ~ .gitconfig "${bakdir}"
    bak_file ~ .clang-format "${bakdir}"
    info "bak all file successfully"
}

install_dotfile() {
    bak_config
    ## alacritty
    if program_already_installed alacritty; then
        mkdir -p ~/.config/alacritty
        if cp "$PWD/.alacritty.yml" ~/.config/alacritty/alacritty.yml; then
            info "dotfile:alacritty install successfully!"
        else
            error "dotfile:alacritty install failed!"
        fi
    fi

    if [ "$(check_os_type)" = "Arch" ]; then
        #pacman cmd
        cp "$PWD/.pacman_cmd.zsh" ~
        info "dotfile:pacman_cmd install successfully!"
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
    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh && cp "$PWD/.sshconfig" ~/.ssh/config
    info "dotfile:ssh config install successfully!"

    ### ideavim
    cp "$PWD/.ideavimrc" ~/.ideavimrc
    info "dotfile:ideavimrc install successfully!"

    ### gdbinit
    if wget -P ~ git.io/.gdbinit; then
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

    ## fzf
    cp "$PWD/.fzf_custom.zsh" ~
    if git clone https://github.com/DanielFGray/fzf-scripts.git ~/.fzf-scripts; then
        info "dotfile:fzf_custom install successfully!"
    else
        error "dotfile:fzf_custom install failed!"
    fi

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
    mkdir -p ~/.cht.sh/bin
    curl https://cht.sh/:cht.sh >~/.cht.sh/bin/cht.sh
    chmod u+x ~/.cht.sh/bin/cht.sh
    info "dotfile:cheat.sh install successfully!"

    #切换到zsh
    if sudo chsh -s /bin/zsh; then
        info "change zsh successfully!"
    else
        error "change zsh failed!"
    fi

    ## vim
    if git clone https://github.com/leihuxi/vimrc.git ~/.vim_runtime; then
        sh ~/.vim_runtime/install_awesome_vimrc.sh
        info "dotifile:vimrc install successfully!"
    else
        error "dotfile:vimrc install failed!"
    fi
    info "all installed successfully, Please reboot your shell!"
}

update_software() {
    (cd ~/.oh-my-zsh && git pull)
    (cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull)
    (cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull)
    (cd ~/.fzf-scripts && git pull)
    (bak_file ~ .gdbinit ~/.bakconfig && wget -P ~ git.io/.gdbinit)
}

main() {
    if [[ "$1" -eq "up" ]]; then
        update_software
        pacman -Qqe >"$PWD/.pkglist.txt"
        git diff "$PWD/.pkglist.txt"
        exit
    fi

    if [ "$(check_os_type)" = "Arch" ]; then
        sudo pacman -S --needed - <"$PWD/.pkglist.txt"
    else
        install_program_list_required
    fi

    install_program_third_parted
    install_dotfile
}

main
