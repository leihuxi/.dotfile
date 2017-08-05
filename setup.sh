#!/bin/bash
. $PWD/logger.sh

is_sudo() {
    sudo echo
    if [[ $? -ne 0 ]]; then
        error "This script must be run by root or a sudo'er"
        exit 1
    fi
}

check_os_type() {
    case "$OSTYPE" in
        linux*)   lsb_release -i | awk -F"\t" '{print $2}';;
        darwin*)  echo "Mac" ;;
        win*)     echo "Windows" ;;
        cygwin*)  echo "Cygwin" ;;
        bsd*)     echo "Bsd" ;;
        solaris*) echo "Solaris" ;;
        *)        echo "Unknown: $OSTYPE" ;;
    esac
}

program_already_installed() {
    command -v "$@" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 1
    fi
    return 0
}

install_program() {
    local progam_name=$1
    local os=$(check_os_type)
    local is_setup=$(program_already_installed "${progam_name}")
    if [[ $is_setup -ne 0 ]]; then
        if [[ $os = "Ubuntu" ]]; then
            apt install "${progam_name}"
        elif [[ $os = "Mac" ]]; then
            brew install "${progam_name}"
        elif [[ $os = "CentOS" ]]; then
            yum install "${progam_name}"
        fi
        if [[ $? -ne 0 ]]; then
            error "${progam_name} install failed!"
            exit 1
        fi
        info "${progam_name} is install successfully!"
    else
        info "${progam_name} is already installed"
    fi
}

bak_file() {
    cp "$1" "$1_$(date -d now +%Y%m%d%H%M%S)_dotfile"
}


install_required_program() {
    install_program curl
    install_program git
    install_program vim
    install_program zsh
    install_program tmux
}

install_dotfile() {
    if [[ ! -d ~/.vim_runtime ]]; then
        git clone git://github.com/leihuxi/vimrc.git ~/.vim_runtime
        if [[ $? -eq 0 ]]; then
            bak_file ~/.vimrc
            sh ~/.vim_runtime/install_awesome_vimrc.sh
            info "dotifile:vimrc install successfully!"
        else
            error "dotfile:vimrc install failed"
        fi
    fi

    if [[ ! -d ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        if [[ $? -eq 0 ]]; then
            bak_file ~/.zshrc
            cp "$PWD/.zshrc" ~
            info "dotfile:zshrc install successfully!"
        else
            error "dotfile:zshrc install failed"
        fi
    fi

    if [[ ! -d ~/.tmux ]]; then
        git clone https://github.com/gpakosz/.tmux.git ~/.tmux
        if [[ $? -eq 0 ]]; then
            bak_file ~/.tmux.conf
            ln -s -f .tmux/.tmux.conf ~/.tmux.conf
            cp "$PWD/.tmux.conf.local" ~
            info "dotfile:tmux.conf install successfully!"
        else
            error "dotfile:zshrc install failed"
        fi
    fi

    if [[ ! -f ~/.ssh/config ]]; then
        cp "$PWD/.sshconfig" ~/.ssh/config
        info "dotfile:ssh config install successfully!"
    fi

    if [[ ! -f ~/.ideavimrc ]]; then
        cp "$PWD/.ideavimrc" ~/.ideavimrc
        info "dotfile:ideavimrc install successfully!"
    fi
    info "all installed successfully"
}

main() {
    is_sudo
    install_required_program
    install_dotfile
}
main
