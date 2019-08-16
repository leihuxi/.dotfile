#!/bin/bash

echo "mirrorlist set"
tmpfile=$(mktemp --suffix=-mirrorlist)
echo ${tmpfile}
curl -so "${tmpfile}" "https://www.archlinux.org/mirrorlist/?country=CN&use_mirror_status=on"
sed -i 's/^#Server/Server/g' ${tmpfile}
cp ${tmpfile} /etc/pacman.d/mirrorlist
pacman -Sy pacman-contrib
rankmirrors ${tmpfile} > /etc/pacman.d/mirrorlist
pacstrap /mnt base iw grub efibootmgr zsh vim
genfstab -U >> /mnt/etc/fstab
