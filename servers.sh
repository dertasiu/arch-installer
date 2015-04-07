LAMP=0
user=$(cat /etc/passwd | grep 1000 | awk -F':' '{ print $1}' | head -1)
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
			pacman -Syy --noconfirm openssh
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
						sed -i -e "s/#Port 22/Port $(echo $port)/g" /etc/ssh/sshd_config
					fi;;
				1) echo "Port not changed";;
			esac
		;;

		"Web")
			pacman -Syy --noconfirm apache php php-apache mariadb

			mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
			'/usr/bin/mysqladmin' -u root password 'mysql'
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers
			LAMP=1
		;;

		"Owncloud")
			if [[ $LAMP == "0" ]]; then
				web
			fi
			pacman -Syy --noconfirm owncloud
		;;

		"Wordpress")
			if [[ $LAMP == "0" ]]; then
				web
			fi
			pacman -Syy --noconfirm wordpress
		;;

		"Subsonic")
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD:ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -Syy -A --noconfirm subsonic
			sed -i '/%wheel ALL=(ALL) NOPASSWD:ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
		;;

		"NTOP")
			pacman -Syy --noconfirm ntop
			systemctl enable ntop
			systemctl start ntop
		;;

		"TightVNC")
			pacman -Syy --noconfirm 
		;;

		"Deluge")
			yaourt -Syy --noconfirm 
		;;

		"PPTP")
			pacman -Syy --noconfirm 
		;;

		"Prosody")
			pacman -Syy --noconfirm 
		;;
esac
done