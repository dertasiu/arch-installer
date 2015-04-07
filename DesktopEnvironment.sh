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
		Budige " "	off
		)
desktop=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $desktop
do
	case $choice in
		"KDE4")
			pacman -Syy --noconfirm kde
		;;

		"KDE5")
			pacman -Syy --noconfirm plasma
		;;

		"Gnome")
			pacman -Syy --noconfirm gnome gnome-extra
		;;

		"MATE")
			pacman -Syy --noconfirm mate mate-extra
		;;

		"Pantheon")
			yaourt -Syy --noconfirm pantheon-session-bzr
		;;

		"XFCE")
			pacman -Syy --noconfirm xfce4
		;;

		"LXDE")
			pacman -Syy --noconfirm lxde-common
		;;

		"LXQT")
			pacman -Syy --noconfirm lxqt
		;;

		"Unity")
			printf "[Unity-for-Arch]\nSigLevel = Optional TrustAll\nServer = http://dl.dropbox.com/u/486665/Repos/$repo/$arch\[Unity-for-Arch-Extra]\nSigLevel = Optional TrustAll\nServer = http://dl.dropbox.com/u/486665/Repos/$repo/$arch" >> /etc/pacman.conf
			yaourt -Syy --noconfirm unity
		;;

		"DDE")
			arch=$(uname -m)
			printf "[home_metakcahura_arch-deepin_Arch_Extra]\nSigLevel = Never\nServer = http://download.opensuse.org/repositories/home:/metakcahura:/arch-deepin/Arch_Extra/$arch" >> /etc/pacman.conf
			pacman -Syy --noconfirm deepin deepin-extra
		;;

		"OpenBox")
			pacman -Syy --noconfirm openbox
		;;

		"i3")
			pacman -Syy --noconfirm i3
		;;

		"Cinnamon")
			pacman -Syy --noconfirm cinnamon
		;;

		"Budgie")
			yaourt -Syy --noconfirm  budgie-desktop-git
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