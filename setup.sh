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
        linux*)   echo $(lsb_release -i | awk -F"\t" '{print $2}');;
        darwin*)  echo "Mac" ;;
        win*)     echo "Windows" ;;
        cygwin*)  echo "Cygwin" ;;
        bsd*)     echo "Bsd" ;;
        solaris*) echo "Solaris" ;;
        *)        echo "Unknown: $OSTYPE" ;;
    esac
}

program_already_installed() {
    command -v $@ >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 1
    fi
    return 0
}

install_program() {
    local progam_name=$1
    local os=$(check_os_type)
    local is_setup=$(program_already_installed ${progam_name})
    if [[ $is_setup -eq 0 ]]; then
        if [[ $os = "Ubuntu" ]]; then
            apt install ${progam_name}
        elif [[ $os = "Mac" ]]; then
            brew install ${progam_name}
        elif [[ $os = "CentOS" ]]; then
            yum install ${progam_name}
        fi
        if [[ $? -ne 0 ]]; then
            warning "Vim install failed!"
            return
        fi
        info "${progam_name} is install successfully!"
    else
        warning "${progam_name} already installed!"
    fi
}

bak_file() {
    cp $1 $1"_$(date -d now +%Y%m%d%H%M%S)_dotfile"
}


install_dotfile() {
    install_program curl
    install_program vim
    if [[ ! -d ~/.vim_runtime ]]; then
        bak_file ~/.vimrc
        git clone git://github.com/leihuxi/vimrc.git ~/.vim_runtime
        sh ~/.vim_runtime/install_awesome_vimrc.sh
    fi

    install_program zsh
    if [[ ! -d ~/.oh_my_zsh ]]; then
        bak_file ~/.zshrc
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        cp $PWD/.zshrc ~
    fi

    install_program tmux
    if [[ ! -d ~/.tmux ]]; then
        bak_file ~/.tmux.conf
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        git clone https://github.com/gpakosz/.tmux.git ~/.tmux
        ln -s -f .tmux/.tmux.conf
        cp $PWD/.tmux.conf.local ~
    fi

    if [[ -f ~/.ssh/config ]]; then
        bak_file ~/.ssh/config
        cp $PWD/.sshconfig ~/.ssh/config
        info "sshconfig install successfully!"
    fi

    if [[ -f ~/.ideavimrc ]]; then
        bak_file ~/.ideavimrc
        cp $PWD/.ideavimrc ~/.ideavimrc
        info "ideavimrc install successfully!"
    fi
}

main() {
    is_sudo
    install_dotfile
}
main
