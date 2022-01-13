#!/bin/bash

SHELL_FOLDER=$(dirname "$0")
. $SHELL_FOLDER/logger.sh

if [ $# -ne 2 ]; then
    info "./arch_install.sh {username} {intel or amd or other}"
    exit
fi

USERNAME="$1"
CPUTYPE="$2"
ZONE=Asia
SUBZONE=Shanghai
LOCALE_UTF8_US=en_US.UTF-8
LOCALE_UTF8_CN=zh_CN.UTF-8
HOST_NAME=archlinux

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    info "you hit Ctrl-C/Ctrl-\, now exiting.."
}

function arch_chroot() {
    arch-chroot /mnt /bin/bash -c "$1"
}

echo "mirrorlist set"
tmpfile=$(mktemp --suffix=-mirrorlist)
info "${tmpfile}"
curl -so "${tmpfile}" "https://archlinux.org/mirrorlist/?country=CN&use_mirror_status=on"
sed -i 's/^#Server/Server/g' "${tmpfile}"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
cp "${tmpfile}" /etc/pacman.d/mirrorlist
pacman -Sy pacman-contrib
rankmirrors "${tmpfile}" >/etc/pacman.d/mirrorlist
pacman -Sy archlinux-keyring

if [[ "$CPUTYPE" == "amd" ]]; then
    pacstrap /mnt base linux linux-firmware iw grub efibootmgr zsh vim dhcpcd dhclient sudo amd-ucode tmux desktop-file-utils rust xorg xorg-xinit xorg-xrandr feh imagemagick xautolock redshift pulseaudio alsa-utils pulseaudio-alsa xorg-xbacklight chromium dunst scrot neofetch cmake freetype2 fontconfig pkg-config make libxcb libxkbcommon python3 fcitx fcitx-googlepinyin compton alacritty prettyping bat tealdeer global ctags the_silver_searcher xclip ncdu lolcat clang
elif [[ "$CPUTYPE" == "intel" ]]; then
    pacstrap /mnt base linux linux-firmware iw iwd grub efibootmgr zsh vim dhcpcd dhclient sudo intel-ucode tmux desktop-file-utils rust xorg xorg-xinit xorg-xrandr feh i3 xautolock redshift pulseaudio alsa-utils pulseaudio-alsa xorg-xbacklight chromium dunst scrot neofetch cmake freetype2 fontconfig pkg-config make libxcb libxkbcommon python3 fcitx fcitx-googlepinyin compton alacritty prettyping bat tealdeer global ctags the_silver_searcher xclip ncdu lolcat clang
else
    pacstrap /mnt base linux linux-firmware iw iwd grub efibootmgr zsh vim dhcpcd dhclient sudo tmux desktop-file-utils rust xorg  xorg-xinit xorg-xrandr feh i3 imagemagick xautolock redshift pulseaudio alsa-utils pulseaudio-alsa xorg-xbacklight chromium dunst scrot neofetch cmake freetype2 fontconfig pkg-config make libxcb libxkbcommon python3 fcitx fcitx-googlepinyin compton alacritty prettyping bat tealdeer global ctags the_silver_searcher xclip ncdu lolcat clang
fi

genfstab -U /mnt >/mnt/etc/fstab

cp /etc/pacman.d/mirrorlist.orig /mnt/etc/pacman.d/mirrorlist.orig
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

info "set localtime"
arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
arch_chroot "hwclock --systohc --utc"

info "set hostname"
echo "${HOST_NAME}" >/mnt/etc/hostname
arch_chroot "sed -i '/127.0.0.1/s/$/ '${HOST_NAME}'/' /etc/hosts"
arch_chroot "sed -i '/::1/s/$/ '${HOST_NAME}'/' /etc/hosts"

info "locale-gen"
echo "LANG=$LOCALE_UTF8_US" >/mnt/etc/locale.conf
arch_chroot "sed -i 's/#\('${LOCALE_UTF8_CN}'\)/\1/' /etc/locale.gen"
arch_chroot "sed -i 's/#\('${LOCALE_UTF8_US}'\)/\1/' /etc/locale.gen"
arch_chroot "locale-gen"

info "install bootloader and linux kernel"
# arch_chroot "mkinitcpio -p linux"
arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"

info "create ${USERNAME}"
arch_chroot "useradd -m -g users -G wheel -s /bin/zsh ${USERNAME}"
arch_chroot "sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers"
info "password for ${USERNAME}"
arch_chroot "passwd ${USERNAME}"

info "password for root"
arch_chroot "passwd"
