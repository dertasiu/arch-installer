#!/bin/bash

##Welcome message
dialog --backtitle "ArchLinux Installation" --title "Welcome" --msgbox 'Proceed to the installation:' 6 32

##Keyboard selection
selected=0 #Set the variable $selected to 0, this will help to break the while
while [ $selected == "0" ];do #Create the loop to select the keyboard
	locales="$(localectl list-keymaps | awk '$locales=$locales" Keyboard"')" && locales=$(echo "$locales") #List all tha locales avaiable and add it a "Keyboard to the end, this is done because it have to fit in the menu. Then echo itself to generate a list.
	keyboard=$(dialog --backtitle "ArchLinux Installation" --clear --title "Choose your keymap: " --menu "Hi! Choose your favorite keymap:" 0 0 0 	${locales} 2>&1 > /dev/tty) #Generate the menu and save the answer to a variable. Redirect the error output(Answer) and redirect all the menu to the terminal.
	if [ $? == 0 ];then #If the answer is "Accept"...
		loadkeys $keyboard #Load the selected keymap
		keymap=$keyboard #Export the keyboard variable to use ir later
		selected=1 #Get out the while
	else #If the selection is cancel...
		dialog --backtitle "ArchLinux Installation" --msgbox "Please, select the keyboard!" 6 32 #Ask the user to select the keyboard and rerun
	fi
done

##Activate WiFi if it needed
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" --yesno "Do you want to connect to a wifi network?" 6 45 #Ask the user if wants to connect to a wifi network
case $? in #In the case that...
	0) wifi-menu;; #0(Accept) is pressed: open the wifi-menu
	1) echo "Continuing!";; #1(Cancel) is pressed: Do nothing
esac

##Partition creation
#Display a list of all disk and partitions available
dialog --backtitle "ArchLinux Installation" --title "Disk Selection" --msgbox 'Please select a disk to install ArchLinux' 6 45
fdisk -l > /tmp/partitions
dialog --backtitle "ArchLinux Installation" --title "Disk Selection" --textbox /tmp/partitions 0 0
rm /tmp/partitions

#Display a little devices list, selected disk will be saved to the variable $disk 
echo "print devices" > /tmp/parted.p #Save available disks in a temporary file
part="$(parted < /tmp/parted.p | grep sd | awk '{if (NR!=1) {print}}')" #Process the temporary file, display only the line that have "sd" and exclude the first line
rm /tmp/parted.p
disk=$(dialog --backtitle "ArchLinux Installation" --clear --title "Disk Select: "  --menu "Choose the Hard Drive that you want to use" 0 0 0 ${part} 2>&1 >/dev/tty)

#Selection of the partition program
partitioner=$(dialog --backtitle "ArchLinux Installation" --clear --title "Choose partition maker program: " --menu "Choose  your favorite partitioner:" 0 0 0\
		"cfdisk" "An ncurses based partitioner" \
		"fdisk" "A command line MBR partitioner" \
		"parted" "" 2>&1 > /dev/tty)
$partitioner $disk

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

#View the available partitions and select the main partition
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
				swap=$part
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
pacstrap /mnt base base-devel grub-bios networkmanager os-prober sudo dialog wget

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
selected=0 #Define the variable $selected to 0, this will be used to scape from the while
timezonedir=/usr/share/zoneinfo #Define the starting directory
while [ "$selected" = "0" ] #While the selection in unselected do...
do
	#This command should output "America", it will make an ls to the timezones dir, stored in the variable $timezonedir. This will be used in the case that you were on the main timezone dir.
	check=$(ls -l $timezonedir | grep -v .tab | awk '/drwx/' | awk -F " " '{print $9}' | awk '{if (NR!=1) {print}}' | head -1)
	if [[ $check != America ]]; then #In the case that you wouldn't be in the root of the timezones dir
		echo "../ UP" >timezones #Set an option to go up a dir in the menu
	fi
	#Get a list of folders in the timezone dir and save it to the temporal file: timezones
	ls -l $timezonedir | grep -v .tab | awk '/drwx/' | awk -F " " '{print $9}' | awk '{print $0"/"}' | awk '$fs=$fs" Time"' | awk '{if (NR!=1) {print}}'>>timezones 
	#Get a list of files in the timezone dir and save it to the temporal file: timezones
	ls -l $timezonedir | grep -v .tab | awk '/-rw-/' | awk -F " " '{print $9}' | awk '$fs=$fs" Time"' | awk '{if (NR!=1) {print}}'>>timezones
	timezones=$(cat timezones) #Save all this to a variable called $timezones 
	rm timezones #Delete the temporal file
	timezone=$(dialog --backtitle "ArchLinux Installation" --clear --title "Timezone selection: " \
			--menu "Choose your timezone" 20 51 7 ${timezones} 2>&1 >/dev/tty) #Generate a menu to select the timezone or the folder that will contain the timezone
	if [ "$?" = "0" ] #If a selection is made then...
	then
		if [[ $timezone == *"/"* ]]; then #If the timezone contains an slash, that will mean that is a directory
			timezonedir=$timezonedir/$timezone #Append the selected folder to the main $timezonedir variable
		else #If is a file, link it to its location
			ln -s $timezonedir${timezone} /mnt/etc/timezone
			selected=1 #Set the seleccin done to exit the while
		fi
	fi
done

#Enter the name of the machine (hostname)
dialog --backtitle "Archlinux Installation" --inputbox "Enter the machine's name:" 8 40 2>temp
hostname=$(cat temp)
rm temp
if [ "$?" = "0" ]
then
	echo "$hostname" > /mnt/etc/hostname
fi

#Set the root password
rootpasswd=$(dialog --backtitle "Archlinux Installation" --title "Root passoword" --passwordbox "Please, enter the root password" 0 36 2>&1 > /dev/tty)
arch-chroot /mnt /bin/sh -c "echo root:$rootpasswd | chpasswd"

#Add the main user
dialog --backtitle "Archlinux Installation" --title "User creation" \
		--form "Please, enter the user configuration" 0 0 0 \
		"Username :" 1 1 "user" 1 25 25 30 \
		"Real name:" 2 1 "Human Foo Bar" 2 25 25 30 2>temp
user=$(cat temp | sed -n 1p)
realname=$(cat temp | sed -n 2p | sed 's/^/"/' | sed 's/$/"/')
rm temp
if [ "$?" = "0" ]
then
	arch-chroot /mnt /bin/sh -c "useradd -c $realname -m -g users -G video,audio,lp,optical,games,power,wheel,storage -s /bin/bash $user" #Add the user to the following groups and it create the home directory
	userpasswd=$(dialog --backtitle "Archlinux Installation" --title "User creation" --passwordbox "Please, enter the user password" 0 36 2>&1 > /dev/tty)
	arch-chroot /mnt /bin/bash -c "echo $user:$userpasswd | chpasswd"
fi

#Enable the wheel group in the sudoers file
sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /mnt/etc/sudoers

#Enable dhcpcd
arch-chroot /mnt /bin/bash -c "systemctl enable dhcpcd"

##Aur helpers
#Install Yaourt
printf "\n[archlinuxfr]\nServer = http://repo.archlinux.fr/\x24arch\nSigLevel = Optional TrustAll" >>/mnt/etc/pacman.conf
arch-chroot /mnt /bin/bash -c "pacman -Syy"
arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm yaourt"
#Update yaourt's database
arch-chroot /mnt /bin/bash -c "yaourt -Syy"

#Grub instalation question, It will install grub to the previously selected disk stored in the variable $disk 
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" \
		--yesno "Do you want to install grub" 7 60 
response=$?
case $response in
	0)
		originaldisk=$disk
		disks=$(fdisk -l | grep /dev/sd | grep iB | awk -F " " '{print $2}' | sed 's/://g')
		for disk in $disks
		do
			echo "$disk Disk" >> temp
			fdisk -l $disk | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}' >> temp
		done
		partitions=$(cat temp)
		rm temp

		grubpart=$(dialog --backtitle "ArchLinux Installation" --clear --title "Grub partition/disk selection: " --menu "Choose the disk/partition to install grub in it (The disk that contains base system is $originaldisk): " 0 0 0 ${partitions} 2>&1 > /dev/tty)

		arch-chroot /mnt /bin/bash -c "grub-install $grubpart && grub-mkconfig -o /boot/grub/grub.cfg";;
	1) echo "Grub not installed";;
esac

#Copy the post-insall script to the hard drive
cp DesktopEnvironment.sh /mnt/root
cp servers.sh /mnt/root

#Prepare the system to boot directly to root and run the post-insall script
mkdir /mnt/etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root --noclear %I 38400 linux" > /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "sh post-install.sh" >> /mnt/root/.bashrc
echo -e "if [ -f ~/.bashrc ]; then\n\tsource ~/.bashrc\nfi" >> /mnt/root/.bash_profile

#Umount all the partitions
umount {$rootfs,$bootfs,$homefs,$tmpfs,$usrfs,$varfs,$srvfs,$optfs}
swapoff $swap