LAMP=0
user=$(cat /etc/passwd | grep 1000 | awk -F':' '{ print $1}' | head -1)
cmd=(dialog --backtitle "ArchLinux Installation" --separate-output --checklist "Select the Services that you want to install:" 22 76 16)
options=(SSH "Remote console"	off
		Web "Apache + PHP5 + MariaDB(Mysql) A complete Web Server"	off
		Owncloud "Self-hosted cloud"	off
		Wordpress "Self-hosted blog"	off
		Subsonic "Music Server"	off
		Madsonic "Music Server"	off
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
			systemctl start sshd
			systemctl enable sshd
		;;

		"Web")
			pacman -Syy --noconfirm apache php php-apache mariadb
			##MariaDB
			mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
			systemctl start mysqld

			#Ask for the password of the root's database username
			dialog --backtitle "Archlinux Installation" --inputbox "Enter the root's password for MySQL/MariaDB:" 8 40 2>temp
			rpassword=$(cat temp)
			rm temp
			if [ "$?" = "0" ]
			then
				/usr/bin/mysqladmin -u root password $rpassword
			fi

			#Add the main user of mysql
			dialog --backtitle "Archlinux Installation" --title "Mysql user creation" \
					--form "\nPlease, enter the mysql user configuration" 25 60 16 \
					"Username :" 1 1 "user" 1 25 25 30 \
					"Password :" 2 1 "passw0rd" 2 25 25 30 2>temp
			dbuser=$(cat temp | sed -n 1p)
			dbpass=$(cat temp | sed -n 2p)
			rm temp
			if [ "$?" = "0" ]
			then
				DB1="CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
				DB2=" GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'localhost' WITH GRANT OPTION;"
				DB="${DB1}${DB2}"
				mysql -uroot -p$rpassword -e "$DB"
			fi

			##Apache+PHP5
			sed -i 's/LoadModule mpm_event_module modules\x2Fmod_mpm_event.so/LoadModule mpm_prefork_module modules\x2Fmod_mpm_prefork.so/g' /etc/httpd/conf/httpd.conf #Replace the first string with the second one
			sed -i '/LoadModule dir_module modules\x2Fmod_dir.so/a LoadModule php5_module modules\x2Flibphp5.so' /etc/httpd/conf/httpd.conf #Append the second string after the first one
			sed -i '/Include conf\x2Fextra\x2Fhttpd-default.conf/a \\n\x23PHP5\nInclude conf\x2Fextra\x2Fphp5_module.conf' /etc/httpd/conf/httpd.conf #Append the second string after the first one
			systemctl enable httpd
			systemctl start httpd

			LAMP=1
		;;

		"Owncloud")
			if [[ $LAMP == "0" ]]; then
				dialog --backtitle "ArchLinux Installation" --title "Oops..." --msgbox 'To install OwnCloud, you have to install and configure a LAMP server before:' 6 30
				pacman -Syy --noconfirm apache php php-apache mariadb
				##MariaDB
				mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
				systemctl start mysqld

				#Ask for the password of the root's database username
				dialog --backtitle "Archlinux Installation" --inputbox "Enter the root's password for MySQL/MariaDB:" 8 40 2>temp
				rpassword=$(cat temp)
				rm temp
				if [ "$?" = "0" ]
				then
					/usr/bin/mysqladmin -u root password $rpassword
				fi

				#Add the main user of mysql
				dialog --backtitle "Archlinux Installation" --title "User creation" \
						--form "\nPlease, enter the user configuration" 25 60 16 \
						"Username :" 1 1 "user" 1 25 25 30 \
						"Password :" 2 1 "passw0rd" 2 25 25 30 2>temp
				dbuser=$(cat temp | sed -n 1p)
				dbpass=$(cat temp | sed -n 2p)
				rm temp
				if [ "$?" = "0" ]
				then
					DB1="CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
					DB2=" GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'localhost' WITH GRANT OPTION;"
					DB="${DB1}${DB2}"
					mysql -uroot -p$rpassword -e "$DB"
				fi

				##Apache+PHP5
				sed -i 's/LoadModule mpm_event_module modules\x2Fmod_mpm_event.so/LoadModule mpm_prefork_module modules\x2Fmod_mpm_prefork.so/g' /etc/httpd/conf/httpd.conf #Replace the first string with the second one
				sed -i '/LoadModule dir_module modules\x2Fmod_dir.so/a LoadModule php5_module modules\x2Flibphp5.so' /etc/httpd/conf/httpd.conf #Append the second string after the first one
				sed -i '/Include conf\x2Fextra\x2Fhttpd-default.conf/a \\n\x23PHP5\nInclude conf\x2Fextra\x2Fphp5_module.conf' /etc/httpd/conf/httpd.conf #Append the second string after the first one
				systemctl enable httpd
				systemctl start httpd

				LAMP=1
			fi
			pacman -Syy --noconfirm owncloud php-intl php-mcrypt
			sed -i '/extension=gd.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=iconv.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=xmlrpc.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=zip.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=bz2.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=curl.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=intl.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=mcrypt.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=openssl.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=pdo_mysql.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=mysql.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf
			echo -e "Include conf/extra/owncloud.conf" >> /etc/httpd/conf/httpd.conf
			chown http:http -R /usr/share/webapps/owncloud/
			#Enter the database's password
			dialog --backtitle "Archlinux Installation" --inputbox "Enter owncloud's database password:" 8 40 2>temp
			ownpass=$(cat temp)
			rm temp
			DB1="CREATE USER 'owncloud'@'localhost' IDENTIFIED BY '$ownpass';"
			DB2=" CREATE DATABASE owncloud;"
			DB3=" GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud'@'localhost' WITH GRANT OPTION;"
			DB="${DB1}${DB2}${DB3}"
			mysql -uroot -p$rpassword -e "$DB"
			systemctl restart httpd
		;;

		"Wordpress")
			if [[ $LAMP == "0" ]]; then
				dialog --backtitle "ArchLinux Installation" --title "Oops..." --msgbox 'To install WordPress, you have to install and configure a LAMP server before:' 6 30
				pacman -Syy --noconfirm apache php php-apache mariadb
				##MariaDB
				mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
				systemctl start mysqld

				#Ask for the password of the root's database username
				dialog --backtitle "Archlinux Installation" --inputbox "Enter the root's password for MySQL/MariaDB:" 8 40 2>temp
				rpassword=$(cat temp)
				rm temp
				if [ "$?" = "0" ]
				then
					/usr/bin/mysqladmin -u root password $rpassword
				fi

				#Add the main user of mysql
				dialog --backtitle "Archlinux Installation" --title "User creation" \
						--form "\nPlease, enter the user configuration" 25 60 16 \
						"Username :" 1 1 "user" 1 25 25 30 \
						"Password :" 2 1 "passw0rd" 2 25 25 30 2>temp
				dbuser=$(cat temp | sed -n 1p)
				dbpass=$(cat temp | sed -n 2p)
				rm temp
				if [ "$?" = "0" ]
				then
					DB1="CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
					DB2=" GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'localhost' WITH GRANT OPTION;"
					DB="${DB1}${DB2}"
					mysql -uroot -p$rpassword -e "$DB"
				fi

				##Apache+PHP5
				sed -i 's/LoadModule mpm_event_module modules\x2Fmod_mpm_event.so/LoadModule mpm_prefork_module modules\x2Fmod_mpm_prefork.so/g' /etc/httpd/conf/httpd.conf #Replace the first string with the second one
				sed -i '/LoadModule dir_module modules\x2Fmod_dir.so/a LoadModule php5_module modules\x2Flibphp5.so' /etc/httpd/conf/httpd.conf #Append the second string after the first one
				sed -i '/Include conf\x2Fextra\x2Fhttpd-default.conf/a \\n\x23PHP5\nInclude conf\x2Fextra\x2Fphp5_module.conf' /etc/httpd/conf/httpd.conf #Append the second string after the first one
				systemctl enable httpd
				systemctl start httpd

				LAMP=1
			fi
			pacman -Syy --noconfirm wordpress
			sed -i '/extension=ftp.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=curl.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=gd.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=iconv.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=pdo_mysql.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=mysql.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=openssl.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=sockets.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=xmlrpc.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			sed -i '/extension=pspell.so/s/^;//g' /etc/php/php.ini #Uncomment the line matching that string
			printf "Alias /wordpress \x22/usr/share/webapps/wordpress\x22\n<Directory \x22/usr/share/webapps/wordpress\x22>\n\tAllowOverride All\n\tOptions FollowSymlinks\n\tRequire all granted\n\tphp_admin_value open_basedir \x22/srv/:/tmp/:/usr/share/webapps/:/etc/webapps:\x24\x22\n</Directory>" > /etc/httpd/conf/extra/httpd-wordpress.conf
			echo -e "\nInclude conf/extra/httpd-wordpress.conf\n" >> /etc/httpd/conf/httpd.conf
			chown http:http -R /usr/share/webapps/wordpress/
			#Enter the database's password
			dialog --backtitle "Archlinux Installation" --inputbox "Enter wordpres' database password:" 8 40 2>temp
			wordpass=$(cat temp)
			rm temp
			DB1="CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '$wordpass';"
			DB2=" CREATE DATABASE wordpress;"
			DB3=" GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' WITH GRANT OPTION;"
			DB="${DB1}${DB2}${DB3}"
			mysql -uroot -p$rpassword -e "$DB"
			systemctl restart httpd
		;;

		"Subsonic")
			pacman -Syy --noconfirm ffmpeg flac lame
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -Syy -A --noconfirm subsonic
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			useradd --system subsonic
			gpasswd --add subsonic audio
			cd /var/lib/subsonic
			chown -R subsonic:subsonic .
			test -d transcode || mkdir transcode
			chown -R root:root transcode
			mkdir /var/lib/subsonic/transcode
			cd /var/lib/subsonic/transcode
			ln -s "$(which ffmpeg)"
			ln -s "$(which flac)"
			ln -s "$(which lame)"

			dialog --backtitle "ArchLinux Installation" --title "Subsonic Configuration" \
					--yesno "Do you want to change the default HTTP port(4040) of Subsonic?" 7 60
			response=$?
			case $response in
				0) dialog --backtitle "Archlinux Installation" --title "Subsonic Configuration" \
							--inputbox "Enter the port that you want to use:" 8 40 2>temp
					port=$(cat temp)
					rm temp
					if [ "$?" = "0" ]
					then
						sed -i "s/SUBSONIC_PORT=4040/SUBSONIC_PORT=$port/g" /var/lib/subsonic/subsonic.sh
					fi;;
				1) echo "HTTP port not changed";;
			esac

			dialog --backtitle "ArchLinux Installation" --title "Subsonic Configuration" \
					--yesno "Do you want to add a HTTPS port to Subsonic?" 7 60
			response=$?
			case $response in
				0) dialog --backtitle "Archlinux Installation" --title "Subsonic Configuration" \
							--inputbox "Enter the port that you want to use:" 8 40 2>temp
					port=$(cat temp)
					rm temp
					if [ "$?" = "0" ]
					then
						sed -i "s/SUBSONIC_HTTPS_PORT=0/SUBSONIC_HTTPS_PORT=$port/g" /var/lib/subsonic/subsonic.sh
					fi;;
				1) echo "HTTPS port not configured";;
			esac
			systemctl enable subsonic
			systemctl start subsonic
		;;

		"Madsonic")
			pacman -Syy --noconfirm ffmpeg flac lame
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -Syy -A --noconfirm madsonic
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			cd /var/madsonic
			test -d transcode || mkdir transcode
			chown -R root:root transcode
			mkdir /var/madsonic/transcode
			cd /var/madsonic/transcode
			ln -s "$(which ffmpeg)"
			ln -s "$(which flac)"
			ln -s "$(which lame)"

			dialog --backtitle "ArchLinux Installation" --title "Madsonic Configuration" \
					--yesno "Do you want to change the default HTTP port(4040) of Madsonic?" 7 60
			response=$?
			case $response in
				0) dialog --backtitle "Archlinux Installation" --title "Madsonic Configuration" \
							--inputbox "Enter the port that you want to use:" 8 40 2>temp
					port=$(cat temp)
					rm temp
					if [ "$?" = "0" ]
					then
						sed -i "s/MADSONIC_PORT=4040/MADSONIC_PORT=$port/g" /lib/madsonic/madsonic.sh
					fi;;
				1) echo "HTTP port not changed";;
			esac

			dialog --backtitle "ArchLinux Installation" --title "Madsonic Configuration" \
					--yesno "Do you want to add a HTTPS port to Madsonic?" 7 60
			response=$?
			case $response in
				0) dialog --backtitle "Archlinux Installation" --title "Madsonic Configuration" \
							--inputbox "Enter the port that you want to use:" 8 40 2>temp
					port=$(cat temp)
					rm temp
					if [ "$?" = "0" ]
					then
						sed -i "s/MADSONIC_HTTPS_PORT=0/MADSONIC_HTTPS_PORT=$port/g" /lib/madsonic/madsonic.sh
					fi;;
				1) echo "HTTPS port not configured";;
			esac
			systemctl enable subsonic
			systemctl start subsonic
		;;

		"NTOP")
			pacman -Syy --noconfirm ntop
			dialog --backtitle "Archlinux Installation" --inputbox "Enter NTOP's admin password:" 8 40 2>temp
			ntoppass=$(cat temp)
			rm temp
			ntop --set-admin-password=$ntoppass
			systemctl enable ntop
			systemctl start ntop
		;;

		"TightVNC")
			pacman -Syy --noconfirm tigervnc
		;;

		"Deluge")
			pacman -Syy --noconfirm deluge python2-pip python2-mako
			pip2.7 install service-identity
			systemctl start deluged
			systemctl enable deluged
			systemctl start deluge-web
			systemctl enable deluge-web
			dialog --backtitle "ArchLinux Installation" --title "Deluege web is now running" --msgbox 'Deluge web is now running at the port 8112, you can change that port in the web UI settings later.' 6 30
		;;

		"PPTP")
			ip=$(ip a | grep inet | grep -v 127.0.0.1 | grep -v ::1/128 | awk -F ' ' '{print $2}' | sed 's/\x2F24//g')

			pacman -Syy --noconfirm xl2tpd ppp lsof python2
			sed -i '/%wheel ALL=(ALL) ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			sudo -u $user yaourt -A -Syy --noconfirm openswan
			sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^/#/g' /etc/sudoers #Comment the line matching that string
			sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers #Uncomment the line matching that string
			iptables --table nat --append POSTROUTING --jump MASQUERADE
			echo "net.ipv4.ip_forward = 1" |  tee -a /etc/sysctl.conf
			echo "net.ipv4.conf.all.accept_redirects = 0" |  tee -a /etc/sysctl.conf
			echo "net.ipv4.conf.all.send_redirects = 0" |  tee -a /etc/sysctl.conf
			echo "net.ipv4.conf.default.rp_filter = 0" |  tee -a /etc/sysctl.conf
			echo "net.ipv4.conf.default.accept_source_route = 0" |  tee -a /etc/sysctl.conf
			echo "net.ipv4.conf.default.send_redirects = 0" |  tee -a /etc/sysctl.conf
			echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" |  tee -a /etc/sysctl.conf
			for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
			sysctl -p
			printf "\x23\x21/usr/bin/env bash\nfor vpn in /proc/sys/net/ipv4/conf/*; do\n\techo 0 > \x24vpn/accept_redirects;\n\techo 0 > \x24vpn/send_redirects;\ndone\niptables --table nat --append POSTROUTING --jump MASQUERADE\n\nsysctl -p" > /usr/local/bin/vpn-boot.sh		;;
			chmod 755 /usr/local/bin/vpn-boot.sh
			printf "[Unit]\nDescription=VPN Settings at boot\nAfter=netctl@eth0.service\nBefore=openswan.service xl2tpd.service\n\n[Service]\nExecStart=/usr/local/bin/vpn-boot.sh\n\n[Install]\nWantedBy=multi-user.target\n" > /etc/systemd/system/vpnboot.service
			systemctl enable vpnboot.service

		"Prosody")
			pacman -Syy --noconfirm 
		;;
esac
done