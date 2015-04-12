user=$(cat /etc/passwd | grep 1000 | awk -F':' '{ print $1}' | head -1)
cmd=(dialog --backtitle "ArchLinux Installation" --separate-output --checklist "Select the Desktop Environment:" 22 76 16)
options=(KDE4 " "	off
		KDE5 " "	off
		Gnome " "	off
		MATE " "	off
		Pantheon " "	off
		XFCE " "	off
		LXDE " "	off
		LXQT " "	off
		Unity " "	off
		DDE " "	off
		OpenBox " "	off
		i3 " "	off
		Cinnamon " "	off
		Budgie " "	off
		Enlightenment " " off
		)
desktop=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $desktop
do
	case $choice in
		"KDE4")
			pacman -Syy --noconfirm kde kde-meta
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"KDE5")
			pacman -Syy --noconfirm plasma plasma-meta
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Gnome")
			pacman -Syy --noconfirm gnome gnome-extra
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"MATE")
			pacman -Syy --noconfirm mate mate-extra
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Pantheon")
			printf "\n[pantheon]\nServer = http://pkgbuild.com/~alucryd/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n" >> /etc/pacman.conf
			pacman -Syy --noconfirm pantheon-session-bzr audience-bzr contractor-bzr eidete-bzr elementary-icon-theme-bzr elementary-icon-theme-bzr elementary-wallpapers-bzr gtk-theme-elementary-bzr footnote-bzr geary indicator-pantheon-session-bzr lightdm-pantheon-greeter-bzr maya-calendar-bzr midori-granite-bzr noise-bzr pantheon-backgrounds-bzr pantheon-calculator-bzr pantheon-default-settings-bzr pantheon-files-bzr pantheon-print-bzr pantheon-terminal-bzr plank-theme-pantheon-bzr scratch-text-editor-bzr snap-photobooth-bzr switchboard-bzr ttf-dejavu ttf-droid ttf-freefont ttf-liberation 
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm ttf-opensans pantheon-notify-bzr
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"XFCE")
			pacman -Syy --noconfirm xfce4 xfce4-goodies
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"LXDE")
			pacman -Syy --noconfirm lxde lxde-common
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"LXQT")
			#Reload pacman's keys, this resolves an issue related to instalation of lxqt
			pacman-key --init
			pacman-key --populate archlinux
			#Install LXQt
			pacman -Syy --noconfirm lxqt oxygen-icons qtcurve
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm qterminal-git obconf-qt-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Unity")
			printf "\n[Unity-for-Arch]\nServer = http://dl.dropbox.com/u/486665/Repos/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n\n[Unity-for-Arch-Extra]\nServer = http://dl.dropbox.com/u/486665/Repos/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n" >> /etc/pacman.conf
			pacman -Syy
			ubuntu=$(pacman -Slq Unity-for-Arch | grep -v upower-compat | grep -v gsettings-desktop-schemas)
			ubuntuextra=$(pacman -Slq Unity-for-Arch-Extra)
			pacman -R --noconfirm gsettings-desktop-schemas glib-networking libsoup networkmanager
			pacman -S --noconfirm ${ubuntu}
			pacman -S --noconfirm networkmanager
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"DDE")
			printf "\n[home_metakcahura_arch-deepin_Arch_Extra]\nServer = http://download.opensuse.org/repositories/home:/metakcahura:/arch-deepin/Arch_Extra/\x24arch\nSigLevel = Never\n" >> /etc/pacman.conf
			pacman -Syy --noconfirm deepin deepin-extra
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"OpenBox")
			pacman -Syy --noconfirm openbox
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"i3")
			pacman -Syy --noconfirm i3
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Cinnamon")
			pacman -Syy --noconfirm cinnamon
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Budgie")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm budgie-desktop-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;
		"Enlightenment")
			pacman -Syy --noconfirm enlightenment
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;
esac
done

dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
		--menu "Select the Session Manager:" 22 76 16 \
		Entrance " " \
		GDM " " \
		LightDM " " \
		LXDM " " \
		MDM " " \
		SDDM " " \
		SLiM " " 2> temp
clear
dm=$(cat temp)
for choice in $dm
do
	case $choice in
		"Entrance")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm entrance-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			systemctl enable entrance
		;;

		"GDM")
			pacman -Syy --noconfirm gdm
			systemctl enable gdm
		;;

		"LightDM")
			pacman -Syy --noconfirm lightdm
			systemctl enable lightdm
		;;

		"LXDM")
			pacman -Syy --noconfirm lxdm
			systemctl enable lxdm
		;;

		"MDM")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm mdm-display-manager
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			systemctl enable mdm
		;;

		"SDDM")
			pacman -Syy --noconfirm sddm
			systemctl enable sddm
		;;

		"SLiM")
			pacman -Syy --noconfirm slim
			systemctl enable slim
		;;
esac
done

#Install the compatibility layer for virtualbox
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" \
		--yesno "Are you on a VirtualBox machine?" 7 60 
response=$?
case $response in
	0) pacman -Syy --noconfirm  virtualbox-guest-utils virtualbox-guest-modules
		modprobe -a vboxguest vboxsf vboxvideo
		systemctl enable vboxservice && systemctl start vboxservice;;
	1) echo "Bye!";;
esac