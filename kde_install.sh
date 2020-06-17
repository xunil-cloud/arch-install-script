#!/bin/sh

fonts_packages="noto-fonts noto-fonts-cjk noto-fonts-emoji"
audio_packages="alsa-utils pulseaudio pulseaudio-alsa pavucontrol"
kde_plasma="plasma-desktop plasma-pa breeze-gtk kde-gtk-config sddm sddm-kcm"
useful_libs="zenity ffmpegthumbs gst-libav gst-plugins-good gst-plugins-base gst-plugins-ugly"
apps="konsole dolphin firefox gwenview kwrite okular youtube-dl"


nm_test=$(pacman -Ss networkmanager |grep '\[installed\]')
if [ ! -z ${nm_test} ]; then
	kde_plasma="${kde_plasma} plasma-nm"
fi

pacman -S ${fonts_packages} ${audio_packages} ${kde_plasma} ${useful_libs} ${apps} --needed

systemctl enable sddm
systemctl set-default graphical.target





