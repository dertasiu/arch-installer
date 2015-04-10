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
		Budige " "	off
		)
desktop=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $desktop
do
	case $choice in
		"KDE4")
			pacman -Syy --noconfirm kde kde-meta
		;;

		"KDE5")
			pacman -Syy --noconfirm plasma plasma-meta
		;;

		"Gnome")
			pacman -Syy --noconfirm gnome gnome-extra
		;;

		"MATE")
			pacman -Syy --noconfirm mate mate-extra
		;;

		"Pantheon")
			printf "\n[pantheon]\nServer = http://pkgbuild.com/~alucryd/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n" >> /etc/pacman.conf
			pacman -Syy --noconfirm pantheon-session-bzr audience-bzr contractor-bzr eidete-bzr elementary-icon-theme-bzr elementary-icon-theme-bzr elementary-wallpapers-bzr gtk-theme-elementary-bzr footnote-bzr geary indicator-pantheon-session-bzr lightdm-pantheon-greeter-bzr maya-calendar-bzr midori-granite-bzr noise-bzr pantheon-backgrounds-bzr pantheon-calculator-bzr pantheon-default-settings-bzr pantheon-files-bzr pantheon-print-bzr pantheon-terminal-bzr plank-theme-pantheon-bzr scratch-text-editor-bzr snap-photobooth-bzr switchboard-bzr ttf-dejavu ttf-droid ttf-freefont ttf-liberation 
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm ttf-opensans pantheon-notify-bzr
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
		;;

		"XFCE")
			pacman -Syy --noconfirm xfce4 xfce4-goodies
		;;

		"LXDE")
			pacman -Syy --noconfirm lxde lxde-common
		;;

		"LXQT")
			pacman -Syy --noconfirm lxqt oxygen-icons qtcurve sddm
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm qterminal-git obconf-qt-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
		;;

		"Unity")
			printf "\n[Unity-for-Arch]\nServer = http://dl.dropbox.com/u/486665/Repos/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n\n[Unity-for-Arch-Extra]\nServer = http://dl.dropbox.com/u/486665/Repos/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n" >> /etc/pacman.conf
			pacman -Syy --noconfirm $(pacman -Slq Unity-for-Arch)
			pacman -Slq Unity-for-Arch-Extra
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm freetype2-ubuntu
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
		;;

		"DDE")
			printf "\n[home_metakcahura_arch-deepin_Arch_Extra]\nServer = http://download.opensuse.org/repositories/home:/metakcahura:/arch-deepin/Arch_Extra/\x24arch\nSigLevel = Never\n" >> /etc/pacman.conf
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
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm budgie-desktop-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
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