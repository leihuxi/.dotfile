if [ $# -ne 1 ]; then
    exit
fi

trap 'custom_exit; exit' SIGINT SIGQUIT
custom_exit() {
    echo "you hit Ctrl-C/Ctrl-\, now exiting.."
}

disk="$1"
disksplit="p"

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

echo "format disk"
mkfs.fat -F 32 "$disk$disksplit"2
mkswap "$disk$disksplit"3
swapon "$disk$disksplit"3
mkfs.ext4 "$disk$disksplit"4
mkfs.ext4 "$disk$disksplit"5

echo "mount disk"
mount "$disk$disksplit"4 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount "$disk$disksplit"2 /mnt/boot
mount "$disk$disksplit"5 /mnt/home
