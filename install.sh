#!/bin/sh

# config
EFI_partition=
EFI_mount_point=/efi
ROOT_partition=
HOME_partition=
UEFI=true

timedatectl set-ntp true

# format partions
echo -e "\e[1;36m\n------ hardrive setup ------\n\e[0m"
echo -e "\e[1;36m\nformat ${ROOT_partition} (root) as ext4... \n\e[0m"
mkfs.ext4 ${ROOT_partition} 
echo -e "\e[1;36m\nformat ${HOME_partition} (home) as ext4... \n\e[0m"
mkfs.ext4 ${HOME_partition}
echo -e "\e[1;36m\nformat ${EFI_partition} (efi) as fat32... \n\e[0m"
read -p $'\e[1;36mDo you want to format efi partion? [y\N] \e[0m' ask_efi_format
ask_efi_format=${ask_efi_format:-n}
if [[ $ask_efi_format =~ ^[Yy]$ ]]
then
   echo
   mkfs.fat -F32 ${EFI_partition} 
fi

# mount partions
mount ${ROOT_partition} /mnt
mkdir /mnt/home
mkdir /mnt${EFI_mount_point}
mount ${EFI_partition} /mnt/efi
mount ${HOME_partition} /mnt/home


echo -e "\e[1;36m\n------ mirrorlist setup ------\n\e[0m"
read -p $'\e[1;36mEdit mirrorlist config? [Y\\n] \e[0m' ask_mirrorlist
ask_mirrorlist=${ask_mirrorlist:-y}
if [[ "$ask_mirrorlist" =~ ^[Yy]$ ]]
then
   vim /etc/pacman.d/mirrorlist 
fi

echo -e "\e[1;36m\n------ install base system ------\n\e[0m"
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "\e[1;36m\n------ base system has been installed ------\n\e[0m"

cp ../arch-install-script*/ -r /mnt
arch-chroot /mnt arch-install-script/post_install.sh

echo -e "\e[1;36m\n------ installation completed! ------\n\e[0m"
read -p $'\e[1;36mUnmount the new system? [Y\\n] \e[0m' ask_umount
ask_umount=${ask_mirrorlist:-y}
if [[ "$ask_umount" =~ ^[Yy]$ ]]
then
   umount -R /mnt 
fi
