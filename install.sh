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

echo -e "\e[1;36m\n------ hardrive setup ------\n\e[0m"

mkfs.ext4 ${ROOT_partition} 
mkfs.ext4 ${HOME_partition}

read -p $'\e[1;36mDo you want to format efi partion? [y\N] \e[0m' -n 1 ask_efi_format
ask_efi_format=${ask_efi_format:-n}
if [[ $ask_efi_format =~ ^[Yy]$ ]]
then
   echo
   mkfs.fat -F32 ${EFI_partition} 
fi


mount ${ROOT_partition} /mnt
mkdir /mnt/home
mkdir /mnt${EFI_mount_point}
mount ${EFI_partition} /mnt/efi
mount ${HOME_partition} /mnt/home


echo -e "\e[1;36m\n------ mirrorlist setup ------\n\e[0m"
read -p '$\e[1;36mEdit mirrorlist config? [Y\n] \e[0m' -n 1 ask_mirrorlist
ask_mirrorlist=${ask_mirrorlist:-y}
if [[ $ask_mirrorlist =~ ^[Yy]$ ]]
then
   vim /etc/pacman.d/mirrorlist 
fi

echo -e "\e[1;36m\n------ install base system ------\n\e[0m"

pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

echo -e "\e[1;36m\n------ base system has been installed ------\n\e[0m"

cp post_install.sh /mnt
arch-chroot /mnt ./post_install.sh


umount -R /mnt
echo -e "\e[1;36m\n------ installation completed! ------\n\e[0m"