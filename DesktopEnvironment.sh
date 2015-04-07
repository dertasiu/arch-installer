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
		)
desktop=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $desktop
do
	case $choice in
		"KDE4")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm kde"
		;;

		"KDE5")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm plasma"
		;;

		"Gnome")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm gnome gnome-extra"
		;;

		"MATE")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm mate mate-extra"
		;;

		"Pantheon")
			arch-chroot /mnt /bin/bash -c "yaourt -Syy --noconfirm pantheon-session-bzr"
		;;

		"XFCE")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm xfce4"
		;;

		"LXDE")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm lxde-common"
		;;

		"LXQT")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm lxqt"
		;;

		"Unity")
			printf "[Unity-for-Arch]\nSigLevel = Optional TrustAll\nServer = http://dl.dropbox.com/u/486665/Repos/$repo/$arch\[Unity-for-Arch-Extra]\nSigLevel = Optional TrustAll\nServer = http://dl.dropbox.com/u/486665/Repos/$repo/$arch" >> /mnt/etc/pacman.conf
			arch-chroot /mnt /bin/bash -c "yaourt -Syy --noconfirm unity"
		;;

		"DDE")
			arch=$(uname -m)
			printf "[home_metakcahura_arch-deepin_Arch_Extra]\nSigLevel = Never\nServer = http://download.opensuse.org/repositories/home:/metakcahura:/arch-deepin/Arch_Extra/$arch" >> /mnt/etc/pacman.conf
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm deepin deepin-extra"
		;;

		"OpenBox")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm openbox"
		;;

		"i3")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm i3"
		;;

		"Cinnamon")
			arch-chroot /mnt /bin/bash -c "pacman -Syy --noconfirm cinnamon"
		;;

		"Budgie")
			arch-chroot /mnt /bin/bash -c "yaourt -Syy --noconfirm  budgie-desktop-git"
		;;
esac
done