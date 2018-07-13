#!/bin/sh
. "$PWD/logger.sh"

is_sudo() {
    if sudo echo; then
        error "This script must be run by root or a sudo'er"
        exit 1
    fi
}

check_os_type() {
    case "${OSTYPE}" in
        linux-gnu)  echo "Arch";;
        linux*)   lsb_release -i | awk -F"\\t" '{print $2}';;
        darwin*)  echo "Mac" ;;
        win*)     echo "Windows" ;;
        cygwin*)  echo "Cygwin" ;;
        bsd*)     echo "Bsd" ;;
        solaris*) echo "Solaris" ;;
        *)        echo "Unknown: $OSTYPE" ;;
    esac
}

program_already_installed() {
    if command -v "$@" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

install_program() {
    local program_name
    local os
    local is_setup
    program_name="$1"
    os=$(check_os_type)
    info "you os is ${os}, install ${program_name}"
    is_setup=$(program_already_installed "${program_name}")
    if [[ "$is_setup" -eq 0 ]]; then
        if [[ "$os" = "Ubuntu" ]]; then
            sudo apt install ${program_name}
        elif [[ "$os" = "Arch" ]]; then
	        sudo pacman -Sy ${program_name}
        elif [[ "$os" = "Mac" ]]; then
            brew install ${program_name}
        elif [[ "$os" = "CentOS" ]]; then
            sudo yum install ${program_name}
        fi
        if [[ $? -ne 0 ]]; then
            error "${program_name} install failed!"
            exit 1
        fi
        info "${program_name} is install successfully!"
    else
        info "${program_name} is already installed"
    fi
}

bak_file() {
    src_dir="$1"
    filename="$2"
    dst_dir="$3"
    src_file="${src_dir}/${filename}"
    if [[ -f "${src_file}" || -d "${src_file}" ]]; then
	info "bak ${src_file} to $dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
        mv "${src_file}" "$dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
    fi
}

install_program_list_required() {
    applist_all_os="go ctags global curl git vim zsh tmux wget cmake python the_silver_searcher powerline-fonts"
    applist_all_os="${applist_all_os} jq expac shellcheck xmlstarlet pandoc cowsay lolcat xsel rlwrap tldr"
    applist_all_os="${applist_all_os} python-setuptools python-appdirs python-pyparsing python-setuptools python-six"
    applist_all_os="${applist_all_os} alacritty-git alacritty-terminfo-git"
    #fix ycm arch bug
    if [ "$OSTYPE" == "linux-gnu" ]; then
        applist_all_os="${applist_all_os} ncurses5-compat-libs"
    fi
    install_program "${applist_all_os}"
    sudo pip install pep8 flake8 pyflakes isort yapf
    sudo pip install cheat howdoi
}

bak_config() {
    bakdir=~/.bakconfig
    [[ -d "${bakdir}" ]] || mkdir "${bakdir}"
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
    info "bak all file successfully"
}

install_dotfile() {
    bak_config
    ## alacritty
    if cp "$PWD/.alacritty.yml" ~/.config/alacritty/alacritty.yml; then
        info "dotfile:alacritty install successfully!"
    else
        error "dotfile:alacritty install failed!"
    fi

    ### tmux
    if git clone https://github.com/gpakosz/.tmux.git ~/.tmux; then
        ln -s -f .tmux/.tmux.conf ~/.tmux.conf
        cp "$PWD/.tmux.conf.local" ~
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

    #Xconfig
    cp "$PWD/.xprofile" ~
    cp "$PWD/.Xresources" ~
    cp "$PWD/.xinitrc" ~
    info "dotfile:xconfig install successfully!"

    #pacman cmd
    cp "$PWD/.pacman_cmd.zsh" ~
    info "dotfile:pacman_cmd install successfully!"

    #cheat.sh
    mkdir -p ~/.cht.sh/bin
    curl https://cht.sh/:cht.sh > ~/.cht.sh/bin/cht.sh
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

main() {
    #install_required_program
    install_program_list_required
    install_dotfile
}

main
