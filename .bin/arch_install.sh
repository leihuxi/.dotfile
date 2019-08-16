#!/bin/bash
if [ $# -ne 1 ]; then
    exit
fi

disk="$1"
ZONE=Asia
SUBZONE=Shanghai
LOCALE_UTF8_US=en_US.UTF-8
LOCALE_UTF8_CN=zh_CN.UTF-8
HOST_NAME=archlinux
USERNAME=xileihu

umount -R /mnt
parted -a optimal $disk mklabel gpt
parted -a optimal $disk mkpart primary fat32 1Mib 3Mib
parted -a optimal $disk name 1 grub
parted -a optimal $disk set 1 bios_grub on
parted -a optimal $disk mkpart primary fat32 3Mib 131Mib
parted -a optimal $disk name 2 boot
parted -a optimal $disk mkpart primary linux-swap 131Mib 16515Mib
parted -a optimal $disk name 3 swap
parted -a optimal $disk mkpart primary ext4 16515Mib 82051Mib
parted -a optimal $disk name 4 rootfs
parted -a optimal $disk mkpart primary ext4 82051Mib 100%
parted -a optimal $disk name 5 home
parted -a optimal $disk set 2 boot on

echo "mount disk"
mount "$disk"p4 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount "$disk"p2 /mnt/boot
mount "$disk"p5 /mnt/home

echo "mirrorlist set"
tmpfile=$(mktemp --suffix=-mirrorlist)
echo ${tmpfile}
curl -so "${tmpfile}" "https://www.archlinux.org/mirrorlist/?country=CN&use_mirror_status=on"
sed -i 's/^#Server/Server/g' ${tmpfile}
cp ${tmpfile} /etc/pacman.d/mirrorlist
pacman -Sy pacman-contrib
rankmirrors ${tmpfile} >/etc/pacman.d/mirrorlist
pacman -Sy archlinux-keyring
pacstrap /mnt base iw grub efibootmgr zsh vim iw wireless_tools wpa_supplicant dhclient
genfstab -U >>/mnt/etc/fstab

echo "set localtime"
arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
arch_chroot "hwclock --systohc --utc"

echo "set hostname"
echo "${HOST_NAME}" > /mnt/etc/hostname
arch_chroot "sed -i '/127.0.0.1/s/$/ '${HOST_NAME}'/' /etc/hosts"
arch_chroot "sed -i '/::1/s/$/ '${HOST_NAME}'/' /etc/hosts"

echo "locale-gen"
echo "LANG=$LOCALE_UTF8_US" > /mnt/etc/locale.conf
arch_chroot "sed -i 's/#\('${LOCALE_UTF8_CN}'\)/\1/' /etc/locale.gen"
arch_chroot "sed -i 's/#\('${LOCALE_UTF8_US}'\)/\1/' /etc/locale.gen"
arch_chroot "locale-gen"

echo "install bootloader and linux kernel"
arch_chroot "mkinitcpio -p linux"
arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"

echo "create ${USERNAME}"
arch_chroot "useradd -m -g users -G wheel -s /bin/bash ${USERNAME}"
arch_chroot "sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers"
echo "password for ${USERNAME}"
arch_chroot "passwd ${USERNAME}"

echo "password for root"
arch_chroot "passwd"

echo "unmount /mnt"
mount -R /mnt
