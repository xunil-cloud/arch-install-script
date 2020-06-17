#!/bin/sh

HOSTNAME=PC
BOOT_LOADER_NAME=ArchLinux
EFI_mount_point=/efi

install_networkmanager=true
wifi=false

other_essential_packages="vim base-devel man-db grub efibootmgr git sudo xdg-user-dirs"

echo -e "\e[1;36m\n------ basic system configuration: system time, locale, hostname  ------\n\e[0m"

ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#zh_TW.UTF-8/zh_TW.UTF-8/g' /etc/locale.gen
locale-gen > /dev/null
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1       localhost\n127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" > /etc/hosts


if [ ${install_networkmanager} == true ]; then
	other_essential_packages="${other_essential_packages} networkmanager"
else
	other_essential_packages="${other_essential_packages} dhcpcd"
fi

echo -e "\e[1;36m\n------ install other essential packages  ------\n\e[0m"

pacman -S ${other_essential_packages} --needed

echo -e "\e[1;36m\n------ user account setup ------\n\e[0m"
echo -e "\e[1;36mset root password: \n"
passwd

echo -e "\e[1;36m\ncreate billson user...\n\e[0m"
useradd billson -m -G wheel
echo -e "\e[1;36mset billson password: \n\e[0m"
passwd billson
sudo -u billson xdg-user-dirs-update

read -p "\e[1;36mEdit sudo config? [Y\n] \e[0m" -n 1 ask_sudo
ask_sudo=${ask_sudo:-y}
if [[ $ask_sudo =~ ^[Yy]$ ]]
then
   EDITOR=vim visudo 
fi

if [ ${install_networkmanager} == true ]; then
	systemctl enable NetworkManager > /dev/null
else
    systemctl enable dhcpcd > /dev/null
fi

echo -e "\e[1;36m\n------ install grub ------\n\e[0m"

grub-install --target=x86_64-efi --efi-directory=${EFI_mount_point} --bootloader-id=${BOOT_LOADER_NAME}
grub-mkconfig -o /boot/grub/grub.cfg