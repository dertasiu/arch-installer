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
pacman -Syy
clear
for choice in $desktop #For each line that is on the variable $desktop, grab one line and fit it on the $choice variable
do
	case $choice in #In the case that the $choice variable is..., do... Ex: $choice=KDE5; case $choice in. This will select the KDE5 option
		"KDE4")
			pacman -S --noconfirm kde kde-meta
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"KDE5")
			pacman -S --noconfirm plasma plasma-meta
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Gnome")
			pacman -S --noconfirm gnome gnome-extra
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"MATE")
			pacman -S --noconfirm mate mate-extra
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Pantheon")
			printf "\n[pantheon]\nServer = http://pkgbuild.com/~alucryd/\x24repo/\x24arch\nSigLevel = Optional TrustAll\n" >> /etc/pacman.conf
			pacman -Syy --noconfirm pantheon-session-bzr audience-bzr contractor-bzr eidete-bzr elementary-icon-theme-bzr elementary-icon-theme-bzr elementary-wallpapers-bzr gtk-theme-elementary-bzr footnote-bzr geary indicator-pantheon-session-bzr lightdm-pantheon-greeter-bzr maya-calendar-bzr midori-granite-bzr noise-bzr pantheon-backgrounds-bzr pantheon-calculator-bzr pantheon-default-settings-bzr pantheon-files-bzr pantheon-print-bzr pantheon-terminal-bzr plank-theme-pantheon-bzr scratch-text-editor-bzr snap-photobooth-bzr switchboard-bzr ttf-dejavu ttf-droid ttf-freefont ttf-liberation 
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -S --noconfirm ttf-opensans pantheon-notify-bzr
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"XFCE")
			pacman -S --noconfirm xfce4 xfce4-goodies
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"LXDE")
			pacman -S --noconfirm lxde lxde-common
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
			sudo -u $user yaourt -A -S --noconfirm qterminal-git obconf-qt-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			#Enable NetworkManager
			systemctl enable NetworkManager
			dialog --backtitle "ArchLinux Installation" --clear --title "Window Manager Selecion: " \
					--menu "LXQt requieres an Window Manger to work, select it:" 22 76 16 \
					Openbox " " \
					Kwin " " 2> temp
			clear
			wm=$(cat temp)
			rm temp
			for choice in $wm
			do
				case $choice in
					"Openbox")
						pacman -S --noconfirm openbox
					;;

					"Kwin")
						pacman -S --noconfirm kwin
					;;
			esac
			done
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
			pacman -S --noconfirm openbox
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"i3")
			pacman -S --noconfirm i3
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Cinnamon")
			pacman -S --noconfirm cinnamon
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;

		"Budgie")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -S --noconfirm budgie-desktop-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;
		"Enlightenment")
			pacman -S --noconfirm enlightenment
			#Enable NetworkManager
			systemctl enable NetworkManager
		;;
esac
done

dialog --backtitle "ArchLinux Installation" --clear --title "Display Manager selection: " \
		--menu "Select the Display Manager:" 22 76 16 \
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
			sudo -u $user yaourt -A -S --noconfirm entrance-git
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			systemctl enable entrance
		;;

		"GDM")
			pacman -S --noconfirm gdm
			systemctl enable gdm
		;;

		"LightDM")
			pacman -S --noconfirm lightdm
			systemctl enable lightdm
		;;

		"LXDM")
			pacman -S --noconfirm lxdm
			systemctl enable lxdm
		;;

		"MDM")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -S --noconfirm mdm-display-manager
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			systemctl enable mdm
		;;

		"SDDM")
			pacman -S --noconfirm sddm
			systemctl enable sddm
		;;

		"SLiM")
			pacman -S --noconfirm slim
			systemctl enable slim
		;;
esac
done

dialog --backtitle "ArchLinux Installation" --clear --title "Default Shell selection: " \
		--menu "Select the Default Shell:" 22 76 16 \
		BASH " " \
		SH " " \
		ZSH " " \
		FISH " " \
		CShell " " \
		DASH " " \
		KornShell " " \
		Oh " " \
		rc " " 2> temp
clear
dm=$(cat temp)
for choice in $dm
do
	case $choice in
		"BASH")
			usermod -s /bin/bash root
			usermod -s /bin/bash $user
		;;

		"SH")
			usermod -s /bin/sh root
			usermod -s /bin/sh $user
		;;

		"ZSH")
			pacman -S --noconfirm zsh
			dialog --backtitle "ArchLinux Installation" --clear --title "ZSH selection: " \
					--menu "Select the ZSH theme:" 22 76 16 \
					grml "grml zsh config" \
					oh-my-zsh "oh my zsh" \
					None "Pure ZSH!" 2> temp
			clear
			dm=$(cat temp)
			for choice in $dm
			do
				case $choice in
					"grml")
						pacman -S --noconfirm grml-zsh-config
					;;

					"oh-my-zsh")
						sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
						sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
						sudo -u $user yaourt -S -A --noconfirm oh-my-zsh-git bullet-train-oh-my-zsh-theme-git oh-my-zsh-powerline-theme-git powerline-fonts-git
						sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
						sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
						cp /usr/share/oh-my-zsh/zshrc /home/$user/.zshrc
						cp /usr/share/oh-my-zsh/zshrc /root/.zshrc
						themes=$(ls /usr/share/oh-my-zsh/themes | awk -F "." '{print $1}' | sed -e 's/$/ theme/')
						dialog --backtitle "ArchLinux Installation" --clear --title "Oh my ZSH theme selection: " \
								--menu "Select the Oh my ZSH theme:" 22 76 16 ${themes} 2> temp
						theme=$(cat temp)
						rm temp
						sed -i "s/ZSH_THEME=\x22robbyrussell\x22/ZSH_THEME=\x22$theme\x22/" /home/$user/.zshrc
						sed -i "s/ZSH_THEME=\x22robbyrussell\x22/ZSH_THEME=\x22$theme\x22/" /root/.zshrc
					;;

					"None") none
						echo "Pure ZSH!"
					;;
				esac
			done

			usermod -s /bin/zsh root
			usermod -s /bin/zsh $user
		;;

		"FISH")
			pacman -S --noconfirm fish
			usermod -s /usr/bin/fish root
			usermod -s /usr/bin/fish $user
		;;

		"CShell")
			pacman -S --noconfirm tcsh
			usermod -s /bin/tcsh root
			usermod -s /bin/tcsh $user
		;;

		"DASH")
			pacman -S --noconfirm dash
			usermod -s /bin/dash root
			usermod -s /bin/dash $user
		;;

		"KornShell")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -S -A --noconfirm ksh
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			usermod -s /bin/ksh root
			usermod -s /bin/ksh $user
		;;

		"Oh")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -S -A --noconfirm oh
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			usermod -s /usr/bin/oh root
			usermod -s /usr/bin/oh $user
		;;

		"rc")
			pacman -S --noconfirm 9base
			ln -s /opt/plan9/bin/rc /bin/rc
			usermod -s /bin/rc root
			usermod -s /bin/rc $user
		;;
	esac
done

#Install the compatibility layer for virtualbox or the graphics card driver
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" \
		--yesno "Are you on a VirtualBox machine?" 7 60 
response=$?
case $response in
	0) pacman -S --noconfirm  virtualbox-guest-utils virtualbox-guest-modules
		modprobe -a vboxguest vboxsf vboxvideo
		systemctl enable vboxservice && systemctl start vboxservice;;
	1) graphics=$(lspci -k | grep -A 2 -E "(VGA|3D)")
		if [[ $graphics  = *Intel* || $graphics = *intel* || $graphics = *INTEL* ]]
		then
		        pacman -S xf86-video-intel mesa-libgl
		fi
		if [[ $graphics = *NVIDIA* || $graphics = *nvidia* || $graphics = *Nvidia* ]]
		then
		        pacman -S nvidia
		fi
		if [[ $graphics  = *ATI* || $graphics = *ati* || $graphics = *Ati* || $graphics = *AMD* || $graphics = *amd* || $graphics = *amd* ]]
		then
		        pacman -S xf86-video-ati mesa-libgl mesa-vdpau lib32-mesa-vdpau
		fi
;;
esac