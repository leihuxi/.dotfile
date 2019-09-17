#!/bin/bash
if [ $# -ne 1 ]; then
    exit
fi

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    echo "you hit Ctrl-C/Ctrl-\, now exiting.."
}
##安装参数,适合一个硬盘
disk="$1"
disksplit="p"
boot_order=1
swap_order=2
rootfs_order=3
home_order=4
boot_size=260
swap_size=16
rootfs_size=128

diskprefix="${disk}${disksplit}"
home="${diskprefix}${home_order}"
rootfs="${diskprefix}${rootfs_order}"
swap="${diskprefix}${swap_order}"
boot="${diskprefix}${boot_order}"

boot_end=$boot_size
swap_end=$(($boot_end + $swap_size * 1024))
rootfs_end=$(($swap_end + $rootfs_size * 1024))

echo "home=${home}, boot=${boot}, rootfs=${rootfs}, swap=${swap}"
echo "boot=1Mib, ${boot_end}Mib"
echo "swap=${boot_end}Mib, ${swap_end}Mib"
echo "rootfs=${swap_end}Mib, ${rootfs_end}Mib"
echo "home=${rootfs_end}Mib, 100%"

umount -R /mnt
parted -a optimal "${disk}" mklabel gpt
parted -a optimal "${disk}" mkpart primary fat32 1Mib "${boot_end}"Mib
parted -a optimal "${disk}" set "${boot_order}" esp on
parted -a optimal "${disk}" mkpart primary linux-swap ${boot_end}Mib ${swap_end}Mib
parted -a optimal "${disk}" name "${swap_order}" swap
parted -a optimal "${disk}" mkpart primary ext4 "${swap_end}"Mib "${rootfs_end}"Mib
parted -a optimal "${disk}" name "${rootfs_order}" rootfs
parted -a optimal "${disk}" mkpart primary ext4 "${rootfs_end}"Mib 100%
parted -a optimal "${disk}" name "${home_order}" home

echo "format disk"
mkfs.fat -F 32 "${boot}"
mkswap "${swap}"
swapon "${swap}"
mkfs.ext4 "${rootfs}"
mkfs.ext4 "${home}"

echo "mount disk"
mount "${rootfs}" /mnt
mkdir -p /mnt/{boot,home}
mount "${boot}" /mnt/boot
mount "${home}" /mnt/home
