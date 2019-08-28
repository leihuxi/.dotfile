#!/bin/bash
ZONE=Asia
SUBZONE=Shanghai
LOCALE_UTF8_US=en_US.UTF-8
LOCALE_UTF8_CN=zh_CN.UTF-8
HOST_NAME=archlinux
USERNAME=xileihu

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    echo "you hit Ctrl-C/Ctrl-\, now exiting.."
}

function arch_chroot() {
    arch-chroot /mnt /bin/bash -c "$1"
}

echo "mirrorlist set"
tmpfile=$(mktemp --suffix=-mirrorlist)
echo ${tmpfile}
curl -so "${tmpfile}" "https://www.archlinux.org/mirrorlist/?country=CN&use_mirror_status=on"
sed -i 's/^#Server/Server/g' ${tmpfile}
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
cp ${tmpfile} /etc/pacman.d/mirrorlist
pacman -Sy pacman-contrib
rankmirrors ${tmpfile} >/etc/pacman.d/mirrorlist
pacman -Sy archlinux-keyring
pacstrap /mnt base iw grub efibootmgr zsh vim iw wireless_tools wpa_supplicant dhclient sudo
genfstab -U /mnt >/mnt/etc/fstab

cp /etc/pacman.d/mirrorlist.orig /mnt/etc/pacman.d/mirrorlist.orig
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

echo "set localtime"
arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
arch_chroot "hwclock --systohc --utc"

echo "set hostname"
echo "${HOST_NAME}" >/mnt/etc/hostname
arch_chroot "sed -i '/127.0.0.1/s/$/ '${HOST_NAME}'/' /etc/hosts"
arch_chroot "sed -i '/::1/s/$/ '${HOST_NAME}'/' /etc/hosts"

echo "locale-gen"
echo "LANG=$LOCALE_UTF8_US" >/mnt/etc/locale.conf
arch_chroot "sed -i 's/#\('${LOCALE_UTF8_CN}'\)/\1/' /etc/locale.gen"
arch_chroot "sed -i 's/#\('${LOCALE_UTF8_US}'\)/\1/' /etc/locale.gen"
arch_chroot "locale-gen"

echo "install bootloader and linux kernel"
arch_chroot "mkinitcpio -p linux"
arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"

echo "create ${USERNAME}"
arch_chroot "useradd -m -g users -G wheel -s /bin/zsh ${USERNAME}"
arch_chroot "sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers"
echo "password for ${USERNAME}"
arch_chroot "passwd ${USERNAME}"

echo "password for root"
arch_chroot "passwd"
