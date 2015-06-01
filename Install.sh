: 'Copyright (C) 2015 Andrés Quiceno Hernández, Mario Gordillo Ortiz

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>'

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
dialog --backtitle "ArchLinux Installation" --title "WiFi Connection" --yesno "Do you want to connect to a wifi network?" 6 45 #Ask the user if wants to connect to a wifi network
case $? in #In the case that...
	0) wifi-menu #0(Accept) is pressed: open the wifi-menu
		wifinet=$(netctl list | awk -F " " '{print $2}');;
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
		"cfdisk" "A ncurses based partitioner" \
		"fdisk" "A command line MBR partitioner" \
		"parted" "A command line partitioner" 2>&1 > /dev/tty)
$partitioner $disk

#Show the partitions avaiable on the selected disk
fdisk -l "$disk" > /tmp/partitions
dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0

#Select the main partition
partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
p="$(echo "$partitions")"
part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
	--menu "Choose the partition that you want to use for: /" 0 0 0 ${p} 2>&1 > /dev/tty)
rootfs=$part
p=$(echo "$p" | grep -v $part)

#Format the main partition
fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}' | grep -v cramfs | grep -v hfsplus | grep -v  bfs | grep -v msdos | grep -v minix)"
format=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
	--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty)
case $format in
	ext2) mkfs.ext2 -F $part;;
	ext3) mkfs.ext3 -F $part;;
	ext4) mkfs.ext4 -F $part;;
	ext4dev) mkfs.ext4dev -F $part;;
	f2fs) modprobe f2fs
			mkfs.f2fs $part;;
	jfs) mkfs.jfs -q $part;;
	nilfs2) mkfs.nilfs2 -f $part;;
	ntfs) mkfs.ntfs -q $part;;
	reiserfs) mkfs.reiserfs -f -f $part;;
	vfat) mkfs.vfat -F32 $part;;
	xfs) mkfs.xfs -f $part;;
	brtfs) mkfs.brtfs $part;;
esac

#View the available partitions and select the main partition
cmd=(dialog --backtitle "ArchLinux Installation" --separate-output --checklist "Select options:" 0 0 0)
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
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: boot" 0 0 0 ${p} 2>&1 > /dev/tty )
			bootfs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			bootdir="boot"
			p=$(echo "$p" | grep -v $part)
			;;
		"/home")
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: home" 0 0 0 ${p} 2>&1 > /dev/tty )
			homefs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			homedir="home"
			p=$(echo "$p" | grep -v $part)
			;;
		"/tmp")
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: tmp" 0 0 0 ${p} 2>&1 > /dev/tty )
			tmpfs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			tmpdir="tmp"
			p=$(echo "$p" | grep -v $part)
			;;
		"/usr")
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: usr" 0 0 0 ${p} 2>&1 > /dev/tty )
			usrfs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			usrdir="usr"
			p=$(echo "$p" | grep -v $part)
			;;
		"/var")
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: var" 0 0 0 ${p} 2>&1 > /dev/tty )
			varfs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			vardir="var"
			p=$(echo "$p" | grep -v $part)
			;;
		"/srv")
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: srv" 0 0 0 ${p} 2>&1 > /dev/tty )
			srvfs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			srvdir="srv"
			p=$(echo "$p" | grep -v $part)
			;;
		"/opt")
			#Select the partition
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: opt" 0 0 0 ${p} 2>&1 > /dev/tty )
			optfs=$part
			#Select the format 
			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
			filesystem=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the filesystem type that you want to use" 0 0 0 ${fs} 2>&1 > /dev/tty )
			#Format it!
			mkfs.$filesystem $part
			optdir="opt"
			p=$(echo "$p" | grep -v $part)
			;;
		"swap")
			dialog --backtitle "ArchLinux Installation" --title "Partition Selection" --textbox /tmp/partitions 0 0
			part=$(dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition that you want to use for: swap" 0 0 0 ${p} 2>&1 > /dev/tty)
			mkswap $part
			swapon $part
			swap=$part
			p=$(echo "$p" | grep -v $part)
	esac
done

##Mounts
#First mount the root partition because later we are going to create the folders to mount the partitions there
mount $rootfs /mnt
mkdir -p /mnt/{$bootdir,$homedir,$tmpdir,$usrdir,$vardir,$srvdir,$optdir}
mount $bootfs /mnt/boot 2> /dev/zero
mount $homefs /mnt/home 2> /dev/zero
mount $tmpfs /mnt/tmp 2> /dev/zero
mount $usrfs /mnt/usr 2> /dev/zero
mount $varfs /mnt/var 2> /dev/zero
mount $srvfs /mnt/srv 2> /dev/zero
mount $optfs /mnt/opt 2> /dev/zero

##Install basic system with: The base and the development system (We will want this to compile the majority of packets from AUR), grub, networkmanager and a packet that is useful if we use another OS' grub: os-prober
pacstrap /mnt base base-devel grub-bios networkmanager os-prober sudo dialog wget

##Generate the fstab file
genfstab /mnt > /mnt/etc/fstab

###Second phase: Configure the operating system
##Languages and keymaps
#Select the locale
locales="$(cat /mnt/etc/locale.gen | grep _ | sed '1,4d' | sed 's/\(.\{1\}\)//')"
locale=$(dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
	--menu "Choose your language" 0 0 0 ${locales} 2>&1 > /dev/tty)
sed -i "/${locale}/ s/# *//" /mnt/etc/locale.gen

#Select and generate the locale
locales="$(cat /mnt/etc/locale.gen | grep _ | sed '/#/d')"
locale=$(dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
	--menu "Choose your language" 0 0 0 ${locales} 2>&1 > /dev/tty)
echo "LANG=$locale" > /mnt/etc/locale.conf
arch-chroot /mnt /bin/bash -c "locale-gen"

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
			--menu "Choose your timezone" 0 0 0 ${timezones} 2>&1 >/dev/tty) #Generate a menu to select the timezone or the folder that will contain the timezone
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
hostname=$(dialog --backtitle "Archlinux Installation" --inputbox "Enter the machine's name:" 0 0 2>&1 > /dev/tty)
echo "$hostname" > /mnt/etc/hostname

#Set the root password
rootpasswd=$(dialog --backtitle "Archlinux Installation" --title "Root passoword" --passwordbox "Please, enter the root password" 8 36 2>&1 > /dev/tty)
arch-chroot /mnt /bin/sh -c "echo root:$rootpasswd | chpasswd"

#Add the main user
username=$(dialog --backtitle "Archlinux Installation" --title "User creation" \
					--form "Please, enter the user configuration" 0 0 0 \
						"Username :" 1 1 "user" 1 12 25 30 \
						"Real name:" 2 1 "Nicolas Cage" 2 12 25 30 2>&1 > /dev/tty)
user=$(echo "$username" | sed -n 1p)
realname=$(echo "$username" | sed -n 2p | sed 's/^/"/' | sed 's/$/"/')
arch-chroot /mnt /bin/sh -c "useradd -c $realname -m -g users -G video,audio,lp,optical,games,power,wheel,storage -s /bin/bash $user" #Add the user to the following groups and it create the home directory
userpasswd=$(dialog --backtitle "Archlinux Installation" --title "User creation" --passwordbox "Please, enter the user password" 8 36 2>&1 > /dev/tty)
arch-chroot /mnt /bin/bash -c "echo $user:$userpasswd | chpasswd"

#Enable the wheel group in the sudoers file
sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /mnt/etc/sudoers

#Enable dhcpcd
arch-chroot /mnt /bin/bash -c "systemctl enable dhcpcd"
if [[ ! -z $wifinet ]];then
	cp /etc/netctl/$wifinet /mnt/etc/netctl/$wifinet
	arch-chroot /mnt /bin/bash -c "netctl enable $wifinet"
fi
##Aur helpers
#Install Yaourt
printf "\n[archlinuxfr]\nServer = http://repo.archlinux.fr/\x24arch\nSigLevel = Optional TrustAll" >>/mnt/etc/pacman.conf
arch-chroot /mnt /bin/bash -c "pacman -Syy"
arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm yaourt"
#Update yaourt's database
arch-chroot /mnt /bin/bash -c "yaourt -Syy"

#Grub instalation question, It will install grub to the previously selected disk stored in the variable $disk 
dialog --backtitle "ArchLinux Installation" --title "Grub instalation" \
		--yesno "Do you want to install grub?" 6 32
case $? in
	0)
		originaldisk=$disk
		disks=$(fdisk -l | grep /dev/sd | grep iB | awk -F " " '{print $2}' | sed 's/://g')
		for disk in $disks
		do
			echo "$disk Disk" >> temp
			sleep 2
			fdisk -l $disk | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}' >> temp
		done
		partitions=$(cat temp) && rm temp
		grubpart=$(dialog --backtitle "ArchLinux Installation" --clear --title "Grub partition/disk selection: " --menu "Choose the disk/partition to install grub in it (The disk that contains base system is $originaldisk): " 0 0 0 ${partitions} 2>&1 > /dev/tty)
		arch-chroot /mnt /bin/bash -c "grub-install $grubpart && grub-mkconfig -o /boot/grub/grub.cfg";;
esac


#Copy the post-insall script to the hard drive
cp post-install.sh /mnt/root && chmod +x /mnt/root/post-install.sh
sed -i "s/selectedkeymap/${keymap}/g" /mnt/root/post-install.sh

#Prepare the system to boot directly to root and run the post-insall script
mkdir /mnt/etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root --noclear %I 38400 linux" > /mnt/etc/systemd/system/getty@tty1.service.d/override.conf
echo "sh post-install.sh" >> /mnt/root/.bashrc
echo -e "if [ -f ~/.bashrc ]; then\n\tsource ~/.bashrc\nfi" >> /mnt/root/.bash_profile

#Umount all the partitions
umount {$rootfs,$bootfs,$homefs,$tmpfs,$usrfs,$varfs,$srvfs,$optfs}
swapoff $swap 2> /dev/null

#Warn the user that the computer is going to reboot
dialog --backtitle "ArchLinux Installation" --title "Attention" --msgbox 'The computer is going to reboot to finish the installation' 6 62

#Reboot the computer
reboot