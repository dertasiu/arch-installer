#!/bin/bash

##Basic welcome message
dialog --backtitle "ArchLinux Installation" --title "Welcome" --msgbox 'Proceed to the installation:' 6 30

##Select the wifi network in the case
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" \
		--yesno "Do you want to connect to a wifi network?" 7 60 
response=$?
case $response in
	0) wifi-menu;;
	1) echo "Continuing!";;
esac

##Keyboard type selection
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
localectl list-keymaps > /tmp/original
locales2="$(awk '$locales=$locales" Keyboard"' /tmp/original)" #Save a list of all keymap files available to locales2 variable processing a 2ª column to make the menu
dialog --backtitle "ArchLinux Installation" --clear --title "Choose your keymap: " \
	--menu "Hi! Choose your favorite keymap:" 20 51 7  ${locales2} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		loadkeys $choice #Loads the selected keymap
		keymap=$choice
		rm /tmp/original;;
esac

##Partition creation
#Display a list of all disk and partitions available
dialog --backtitle "ArchLinux Installation" --title "Disk Selection" --msgbox 'Please select a disk to install ArchLinux' 6 30
clear
fdisk -l
echo "You can press Shift + PageUp/PageDown to scroll"
read -p "Press Return to continue..."

#Display a little devices list. Selected disk will be saved to $disk variable
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
echo "print devices" > /tmp/parted.p #Save avaiable disks in a temporary file
part="$(parted < /tmp/parted.p | grep sd | awk '{if (NR!=1) {print}}')" #Process the temporary file. Display line only whith a "sd" and exclude the first line
rm /tmp/parted.p
dialog --backtitle "ArchLinux Installation" --clear --title "Disk Select: " \
	 --menu "Choose the Hard Drive that you want to use" 20 30 7 ${part} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		disk=$choice;;
esac

#Selection of the partition program
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
dialog --backtitle "ArchLinux Installation" --clear --title "Choose partition maker program: " \
	--menu "Choose  your favorite partitioner:" 20 51 7  \
	"cfdisk" " " \
	"fdisk" " " \
	"parted" " " 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		$choice $disk;;
esac

#Select the main partition
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
clear
fdisk -l "$disk"
echo "You can press Shift + PageUp/PageDown to scroll"
read -p "Press Return to continue..."
fdisk -l "$disk" > /tmp/partitions
partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
p="$(echo "$partitions")"
dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
	--menu "Choose the partition that you want to use for: /" 20 30 7 ${p} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		part=$choice
		rootfs=$part
		p=$(echo "$p" | grep -v $part);;
esac

#Format the main partition
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
	--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		mkfs.$choice $part;;
esac

#View avaiable partitions and select the main partition
cmd=(dialog --backtitle "ArchLinux Installation" --separate-output --checklist "Select options:" 22 76 16)
options=("/boot" "Static files of the boot loader" off    # any option can be set to default to "on"
	"/home" "User home directoties" off
	"/tmp" "Temporary files" off
	"/usr" "Static data" off
	"/var" "Variable data" off
	"/srv" "Data for services provided by this system" off
	"/opt" "Add-on aplication software packages" off
	"swap" "Swap file sytem" off
	)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for choice in $choices
do
	case $choice in
		"/boot")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: boot" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				bootfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				bootdir="boot"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"/home")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: home" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				homefs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				homedir="home"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"/tmp")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: tmp" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				tmpfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				tmpdir="tmp"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"/usr")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: usr" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				usrfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				usrdir="usr"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"/var")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: var" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				varfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				vardir="var"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"/srv")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: srv" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				srvfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				srvdir="srv"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"/opt")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: opt" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				optfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 20 30 7 ${fs} 2> temp
			filesystem="$(cat temp)"
			rm temp
			if [ "$?" = "0" ]
			then
				mkfs.$filesystem $part
				optdir="opt"
				p=$(echo "$p" | grep -v $part)
			fi
			;;
		"swap")
			fdisk -l "$disk"
			echo "You can press Shift + PageUp/PageDown to scroll"
			read -p "Press Return to continue..."
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: swap" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				mkswap $part
				swapon $part
				p=$(echo "$p" | grep -v $part)
			fi
	esac
done

parts="$(echo $parts | sed 's/^..//')"

##Mounts
#First mount the root partition because later we are going to create the folders to mount the partitions there
mount $rootfs /mnt
mkdir -p /mnt/{$bootdir,$homedir,$tmpdir,$usrdir,$vardir,$srvdir,$optdir}
mount $bootfs /mnt/boot
mount $homefs /mnt/home
mount $tmpfs /mnt/tmp
mount $usrfs /mnt/usr
mount $varfs /mnt/var
mount $srvfs /mnt/srv
mount $optfs /mnt/opt

##Install basic system with: The base and the development system (We will want this to compile the majority of packets from AUR), grub, networkmanager and a packet that is useful if we use another OS' grub: os-prober
pacstrap /mnt base base-devel grub-bios networkmanager os-prober sudo

##Generate the fstab file
genfstab /mnt > /mnt/etc/fstab

###Second phase: Configure the operating system
##Languages and keymaps
#Select the locale
locales="$(cat /mnt/etc/locale.gen | grep _ | sed '1,4d' | sed 's/\(.\{1\}\)//')"

dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
	--menu "Choose your language" 20 30 7 ${locales} 2> temp
locale="$(cat temp)"
rm temp
if [ "$?" = "0" ]
then
	sed -i "/${locale}/ s/# *//" /mnt/etc/locale.gen
fi

#Select and generate the locale
locales="$(cat /mnt/etc/locale.gen | grep _ | sed '/#/d')"
dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
	--menu "Choose your language" 20 30 7 ${locales} 2> temp
locale="$(cat temp)"
rm temp
if [ "$?" = "0" ]
then
	echo "LANG=$locale" > /mnt/etc/locale.conf
	arch-chroot /mnt /bin/bash -c "locale-gen"
fi

#Keyboard type configuration
echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf

#Select the timezone
selected=0
timezonedir=/usr/share/zoneinfo
while [ "$selected" = "0" ]
do
	check=$(ls -l $timezonedir | grep -v .tab | awk '/drwx/' | awk -F " " '{print $9}' | awk '{if (NR!=1) {print}}' | head -1)
	if [[ $check != America ]]; then
		echo "../ UP" >timezones
	fi
	ls -l $timezonedir | grep -v .tab | awk '/drwx/' | awk -F " " '{print $9}' | awk '{print $0"/"}' | awk '$fs=$fs" Time"' | awk '{if (NR!=1) {print}}'>>timezones
	ls -l $timezonedir | grep -v .tab | awk '/-rw-/' | awk -F " " '{print $9}' | awk '$fs=$fs" Time"' | awk '{if (NR!=1) {print}}'>>timezones
	timezones=$(cat timezones)
	rm timezones
	dialog --backtitle "ArchLinux Installation" --clear --title "Timezone selection: " \
			--menu "Choose your timezone" 20 51 7 ${timezones} 2> temp
	timezone="$(cat temp)"
	rm temp
	if [ "$?" = "0" ]
	then
		if [[ $timezone == *"/"* ]]; then
			timezonedir=$timezonedir/$timezone
		else
			ln -s $timezonedir${timezone} /mnt/etc/timezone
			selected=1
		fi
	fi
done

#Enter the name of the machine (hostname)
dialog --inputbox "Enter the machine's name:" 8 40 2>temp
hostname=$(cat temp)
rm temp
if [ "$?" = "0" ]
then
	echo "$hostname" > /mnt/etc/hostname
fi

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

#Enable the wheel group in the sudoers file
sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /mnt/etc/sudoers

#Enable networkmanager
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"

#Install Yaourt
architecture=$(uname -m)
printf "[archlinuxfr]\nServer = http://repo.archlinux.fr/$architecture\nSigLevel = Optional TrustAll" >>/mnt/etc/pacman.conf
arch-chroot /mnt /bin/bash -c "pacman -Syy"
arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm yaourt"
#Update yaourt's database
arch-chroot /mnt /bin/bash -c "yaourt -Syy"

#Grub instalation question, It will install grub to the previously selected disk stored in the variable $disk 
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" \
		--yesno "Do you want to install grub in the previous selected hard drive" 7 60 
response=$?
case $response in
	0) arch-chroot /mnt /bin/bash -c "grub-install $disk && grub-mkconfig -o /boot/grub/grub.cfg";;
	1) echo "Grub not installed";;
esac