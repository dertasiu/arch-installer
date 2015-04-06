if [[ repeat = "0" ]]
	cmd=(dialog --backtitle "ArchLinux Installation" --separate-output --checklist "Select the Services that you want to install:" 22 76 16)
	options=(SSH "Remote console"	off
			Web "Apache + PHP5 + MariaDB(Mysql) A complete Web Server"	off
			Owncloud "Self-hosted cloud"	off
			Wordpress "Self-hosted blog"	off
			Subsonic "Music Server"	off
			NTOP "Traffic monitoring tool"	off
			TightVNC "Remote screen server"	off
			Deluge "Torrent server with web UI"	off
			PPTP "VirtualPrivateNetwork Server"	off
			Prosody "XMPP Chat Server"	off
			)
	desktop=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $desktop
	do
		case $choice in
			"SSH")
				SSH_INSTALLED=1
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm openssh"
				dialog --backtitle "ArchLinux Installation" --title "SSH Configuration" \
						--yesno "Do you want to change the default port(22) of SSHD?" 7 60 
				response=$?
				case $response in
					0) dialog --backtitle "Archlinux Installation" --title "SSH Configuration" \
								--inputbox "Enter the port that you want to use:" 8 40 2>temp
						port=$(cat temp)
						rm temp
						if [ "$?" = "0" ]
						then
							sed -i -e "s/#Port 22/Port $(echo $port)/g" /mnt/etc/ssh/sshd_config
						fi;;
					1) echo "Port not changed";;
				esac
			;;

			"Web")
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm gnome gnome-extra"
			;;

			"Owncloud")
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm mate mate-extra"
			;;

			"Wordpress")
				arch-root /mnt /bin/bash -c "yaourt -Syy --noconfirm pantheon-session-bzr"
			;;

			"Subsonic")
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm xfce4"
			;;

			"NTOP")
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm lxde-common"
			;;

			"TightVNC")
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm lxqt"
			;;

			"Deluge")
				printf "[Unity-for-Arch]\nSigLevel = Optional TrustAll\nServer = http://dl.dropbox.com/u/486665/Repos/$repo/$arch\[Unity-for-Arch-Extra]\nSigLevel = Optional TrustAll\nServer = http://dl.dropbox.com/u/486665/Repos/$repo/$arch" >> /mnt/etc/pacman.conf
				arch-root /mnt /bin/bash -c "yaourt -Syy --noconfirm unity"
			;;

			"PPTP")
				arch=$(uname -m)
				printf "[home_metakcahura_arch-deepin_Arch_Extra]\nSigLevel = Never\nServer = http://download.opensuse.org/repositories/home:/metakcahura:/arch-deepin/Arch_Extra/$arch" >> /mnt/etc/pacman.conf
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm deepin deepin-extra"
			;;

			"Prosody")
				arch-root /mnt /bin/bash -c "pacman -Syy --noconfirm openbox"
			;;
	esac
	done
fi