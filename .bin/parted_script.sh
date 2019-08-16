#!/bin/bash
if [ $# -ne 1 ] ; then
    exit
fi

disk="$1"
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

mount "$disk"p4 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount "$disk"p2 /mnt/boot
mount "$disk"p5 /mnt/home
