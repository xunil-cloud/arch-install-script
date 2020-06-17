#!/bin/sh

EFI_partition= 
EFI_mount_point=/efi
ROOT_partition= 
HOME_partition= 
UEFI=true

timedatectl set-ntp true

# echo PARTED
# parted $DEVICE mklabel msdos
# parted $DEVICE mkpart primary ext4 1MiB 500MiB
# parted $DEVICE mkpart primary ext4 500MiB 15GiB
# parted $DEVICE set 1 boot on


echo MKFS
mkfs.ext4 ${ROOT_partition}
mkfs.ext4 ${HOME_partition}

echo MOUNT
mount ${ROOT_partition} /mnt
mkdir /mnt/home --verbose
mkdir /mnt${EFI_mount_point} --verbose
mount ${EFI_partition} /mnt/efi
mount ${HOME_partition} /mnt/home

echo MIRROR
vim /etc/pacman.d/mirrorlist

echo INSTALL
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

echo CHROOT
arch-chroot /mnt post_install.sh
echo FINISH_CHROOT
umount -R /mnt

