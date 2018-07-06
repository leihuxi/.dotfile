#!/bin/bash
. "$PWD/logger.sh"

is_sudo() {
    sudo echo
    if [[ $? -ne 0 ]]; then
        error "This script must be run by root or a sudo'er"
        exit 1
    fi
}

check_os_type() {
    case "${OSTYPE}" in
        linux-gnu)  echo "Arch";;
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
    local progam_name
    local os
    local is_setup
    progam_name=$1
    os=$(check_os_type)
    is_setup=$(program_already_installed "${progam_name}")
    if [[ $is_setup -eq 0 ]]; then
        if [[ $os = "Ubuntu" ]]; then
            sudo apt install "${progam_name}"
        elif [[ $os = "Arch" ]]; then
            sudo pacman -Sy "${progam_name}"
        elif [[ $os = "Mac" ]]; then
            brew install "${progam_name}"
        elif [[ $os = "CentOS" ]]; then
            sudo yum install "${progam_name}"
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

install_program_list() {
    str=$1
    arr=(${str//,/ })
    for i in "${arr[@]}"
    do
        install_program $i
    done
}

bak_file() {
    src_dir="$1"
    filename="$2"
    dst_dir="$3"
    src_file="${src_dir}/${filename}"
    if [[ -f "${src_file}" || -d "${src_file}" ]]; then
        mv "${src_file}" "$dst_dir/${filename}_$(date -d now +%Y%m%d%H%M%S)_dotfile"
    fi
}

install_program_list_required() {
    applist="ctags,global,curl,git,vim,zsh,tmux,wget,cmake,npm,ruby,python,the_silver_searcher,jq,expac,mpc,mpd"
    install_program_list $applist
    #fix ycm arch bug
    if [[ $OSTYPE -eq "linux-gnu" ]]; then
        install_program ncurses5-compat-libs
    fi
    install_program tldr
    # sudo npm install -g tldr --unsafe-perm=true --allow-root
    sudo gem install lolcat
    sudo npm -g install instant-markdown-d
    sudo pip install howdoi
}

install_required_program() {
    # is_sudo
    install_program ctags
    install_program global
    install_program curl
    install_program git
    install_program vim
    install_program zsh
    install_program tmux
    install_program wget
    install_program cmake
    install_program python
    install_program the_silver_searcher
    install_program jq
    install_program expac
    # install_program mpc
    # install_program mpd
    install_program shellcheck
    install_program xmlstarlet
    install_program pandoc
    install_program cowsay
    install_program lolcat
    #fix ycm arch bug
    if [[ $OSTYPE -eq "linux-gnu" ]]; then
        install_program ncurses5-compat-libs
    fi
    install_program tldr
    # install_program npm
    # sudo npm install -g tldr --unsafe-perm=true --allow-root
    # install_program ruby
    # sudo gem install lolcat
    # sudo npm -g install instant-markdown-d
    sudo pip install pep8 flake8 pyflakes isort yapf
    sudo pip install cheat howdoi
}

install_program_list

bak_config() {
    bakdir=~/.bakconfig
    [[ -d "${bakdir}" ]] || mkdir "${bakdir}"
    bak_file ~ .vimrc "${bakdir}"
    bak_file ~ .zshrc "${bakdir}"
    bak_file ~ .tmux.conf "${bakdir}"
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
}

install_dotfile() {
    bak_config
    ## alacritty
    curl https://sh.rustup.rs -sSf | sh
    git clone https://github.com/jwilm/alacritty.git ~/.alacritty
    if [[ $? -eq 0 ]]; then
        (cd ~/.alacritty && rustup override set stable && rustup update stable)
        cp "$PWD/.alacritty.yml" ~/.config/alacritty
        info "dotfile:alacritty config install successfully!"
    fi

    ## tmux
    git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    if [[ $? -eq 0 ]]; then
        ln -s -f .tmux/.tmux.conf ~/.tmux.conf
        cp "$PWD/.tmux.conf.local" ~
        info "dotfile:tmux.conf install successfully!"
    else
        error "dotfile:zshrc install failed"
    fi

    ## zsh
    [ ! -d ~/.ssh ] && mkdir -p ~/.ssh && cp "$PWD/.sshconfig" ~/.ssh/config
    info "dotfile:ssh config install successfully!"

    ## ideavim
    cp "$PWD/.ideavimrc" ~/.ideavimrc
    info "dotfile:ideavimrc install successfully!"

    ## gdbinit
    wget -P ~ git.io/.gdbinit
    if [[ $? -eq 0 ]]; then
        info "dotfile:gdbinit install successfully!"
    else
        error "dotfile:gdbinit install failed!"
    fi

    ## oh-my-zsh
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    if [[ $? -eq 0 ]]; then
        cp $PWD/.zshrc ~
        source ~/.zshrc
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
        git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
        ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
        info "dotfile:zshrc install successfully!"
    else
        error "dotfile:zshrc install failed"
    fi

    ## fzf
    cp "$PWD/.fzf_custom.zsh" ~
    git clone https://github.com/DanielFGray/fzf-scripts.git ~/.fzf-scripts

    #Xconfig
    cp "$PWD/.xprofile" ~
    cp "$PWD/.Xresources" ~
    cp "$PWD/.xinitrc" ~

    #pacman cmd
    cp "$PWD/.pacman_cmd.zsh" ~

    ## vim
    git clone https://github.com/leihuxi/vimrc.git ~/.vim_runtime
    if [[ $? -eq 0 ]]; then
        sh ~/.vim_runtime/install_awesome_vimrc.sh
        info "dotifile:vimrc install successfully!"
    else
        error "dotfile:vimrc install failed"
    fi
    source ~/.zshrc
    info "all installed successfully!"
}

main() {
    install_required_program
    install_dotfile
}
main
