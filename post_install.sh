HOSTNAME= 
BOOT_LOADER_NAME=ArchLinux
EFI_mount_point=/efi

install_networkmanager=true
wifi=false


ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#zh_TW.UTF-8/zh_TW.UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo -e "127.0.0.1 localhost\n::1       localhost\n127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" > /etc/hosts

pacman -S vim base-devel man-db grub efibootmgr


echo -e "set root password: \n"
passwd

pacman -S sudo xdg-user-dirs
echo -e "create billson user: \n"
useradd billson -m -G wheel
echo -e "set billson password: \n"
passwd billson
sudo -u billson xdg-user-dirs-update
EDITOR=vim visudo

if [ ${install_networkmanager} ]; then
	pacman -S networkmanager
    systemctl enable networkmanager
else
	pacman -S dhcpcd
    systemctl enable dhcpcd
fi



grub-install --target=x86_64-efi --efi-directory=${EFI_mount_point} --bootloader-id=${BOOT_LOADER_NAME}
grub-mkconfig -o /boot/grub/grub.cfg

