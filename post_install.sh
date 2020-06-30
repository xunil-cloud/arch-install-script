#!/bin/sh

# config
HOSTNAME=PC
BOOT_LOADER_NAME=ArchLinux
EFI_mount_point=/efi
install_networkmanager=true
wifi=false
other_essential_packages="vim base-devel man-db grub efibootmgr git sudo xdg-user-dirs"

# set to 0 if you don't want to ceate a swapfile
SWAP_size=2048 # in Mb

echo -e "\e[1;36m\n------ basic system configuration: system time, locale, hostname  ------\n\e[0m"

ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#zh_TW.UTF-8/zh_TW.UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1       localhost\n127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" > /etc/hosts

# install packages
if [ "${install_networkmanager}" == true ]; then
	other_essential_packages="${other_essential_packages} networkmanager"
else
	other_essential_packages="${other_essential_packages} dhcpcd"
fi

echo -e "\e[1;36m\n------ install other essential packages  ------\n\e[0m"
pacman -S ${other_essential_packages} --needed --noconfirm

echo -e "\e[1;36m\nenable network service...\n\e[0m"
if [ "${install_networkmanager}" == true ]; then
	systemctl enable NetworkManager
else
    systemctl enable dhcpcd
fi

# swapfile
if [[ $SWAP_size != 0 ]]
then
	echo -e "\e[1;36m\n------ setup swapfile ------\n\e[0m"
	dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_size} status=progress
	chmod 600 /swapfile
	mkswap /swapfile
	echo "/swapfile none swap defaults 0 0" >> /etc/fstab
fi

echo -e "\e[1;36m\n------ install grub ------\n\e[0m"
grub-install --target=x86_64-efi --efi-directory=${EFI_mount_point} --bootloader-id=${BOOT_LOADER_NAME}
grub-mkconfig -o /boot/grub/grub.cfg


echo -e "\e[1;36m\n------ user account setup ------\n\e[0m"
echo -e "\e[1;36mset root password: \n\e[0m"
passwd
echo -e "\e[1;36m\ncreate billson user...\n\e[0m"
useradd billson -m -G wheel
echo -e "\e[1;36mset billson password: \n\e[0m"
passwd billson
sudo -u billson xdg-user-dirs-update

# copy script into new system
mv ../arch-install-script* /home/billson/Downloads
chown billson:billson /home/billson/Downloads/arch-install-script* -R

# sudo setup
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
