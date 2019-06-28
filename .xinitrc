#!/bin/sh
# export LANG=zh_CN.UTF-8
# export LANGUAGE=zh_CN:en_US
# export LC_CTYPE=en_US.UTF-8

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# export GTK_IM_MODULE=ibus
# export QT_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

DEFAULT_SESSION='i3 --shmlog-size 0'

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

DEFAULT_SESSION='i3 --shmlog-size 0'
get_session() {
    local dbus_args=(--sh-syntax --exit-with-session)
    case $1 in
    sway) dbus_args+=(sway) ;;
    *) dbus_args+=($DEFAULT_SESSION) ;;
    esac
    echo "dbus-launch ${dbus_args[*]}"
}

exec $(get_session)
