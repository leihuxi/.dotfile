#!/bin/bash

SHELL_FOLDER=$(dirname "$0")
. $SHELL_FOLDER/logger.sh

if [ $# -ne 2 ]; then
    info "./parted_disk.sh {/dev/sda} {split}"
    exit
fi

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    error "you hit Ctrl-C/Ctrl-\, now exiting.."
}
##安装参数,适合一个硬盘
disk="$1"
disksplit="$2"
bios_order=1
boot_order=2
swap_order=3
rootfs_order=4
home_order=5
boot_size=259
swap_size=16
rootfs_size=128

diskprefix="${disk}${disksplit}"
home="${diskprefix}${home_order}"
rootfs="${diskprefix}${rootfs_order}"
swap="${diskprefix}${swap_order}"
boot="${diskprefix}${boot_order}"

bios_end=3
boot_end=$boot_size
swap_end=$(($boot_end + $swap_size * 1024))
rootfs_end=$(($swap_end + $rootfs_size * 1024))

info "home=${home}, boot=${boot}, rootfs=${rootfs}, swap=${swap}"
info "boot=1Mib, ${boot_end}Mib"
info "swap=${boot_end}Mib, ${swap_end}Mib"
info "rootfs=${swap_end}Mib, ${rootfs_end}Mib"
info "home=${rootfs_end}Mib, 100%"

umount -R /mnt
parted -a optimal "${disk}" mklabel gpt
parted -a optimal "${disk}" mkpart primary fat32 1Mib "${bios_end}"Mib
parted -a optimal "${disk}" set "${bios_order}" bios_grub on
parted -a optimal "${disk}" name "${bios_order}" grub
parted -a optimal "${disk}" mkpart primary fat32 3Mib "${boot_end}"Mib
parted -a optimal "${disk}" name "${boot_order}" boot
parted -a optimal "${disk}" set "${boot_order}" boot on
parted -a optimal "${disk}" mkpart primary linux-swap ${boot_end}Mib ${swap_end}Mib
parted -a optimal "${disk}" name "${swap_order}" swap
parted -a optimal "${disk}" mkpart primary ext4 "${swap_end}"Mib "${rootfs_end}"Mib
parted -a optimal "${disk}" name "${rootfs_order}" rootfs
parted -a optimal "${disk}" mkpart primary ext4 "${rootfs_end}"Mib 100%
parted -a optimal "${disk}" name "${home_order}" home

info "format disk"
mkfs.fat -F 32 "${boot}"
mkswap "${swap}"
swapon "${swap}"
mkfs.ext4 "${rootfs}"
mkfs.ext4 "${home}"

info "mount disk"
mount "${rootfs}" /mnt
mkdir -p /mnt/{boot,home}
mount "${boot}" /mnt/boot
mount "${home}" /mnt/home
