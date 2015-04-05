#Add the main user
dialog --backtitle "Archlinux Installation" --title "User creation" \
		--form "\nPlease, enter the user configuration" 25 60 16 \
		"Username :" 1 1 "user" 1 25 25 30 \
		"Real name:" 2 1 "Human Foo Bar" 2 25 25 30 2>temp
user=$(cat temp | sed -n 1p)
realname=$(cat temp | sed -n 2p | sed 's/^/"/' | sed 's/$/"/')
rm temp
if [ "$?" = "0" ]
then
	arch-chroot /mnt /bin/sh -c "useradd -c $realname -m -g users -G video,audio,lp,optical,games,power,wheel,storage -s /bin/bash $user"
	clear
	echo "Please, enter the password that the user will use:"
	arch-chroot /mnt /bin/bash -c "passwd $user"
fi
