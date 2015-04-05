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
	--menu "Choose the partition type that you want to use for: /" 20 30 7 ${p} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		part=$choice
		rootfs=$part;;
esac

#Format the main partition
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
	--menu "Choose the partition type that you want to use" 20 30 7 ${fs} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
	0)
		mkfs.$choice $part
		parts="$parts"",boot"
		p=$(echo "$p" | grep -v $choice);;
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: boot" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				bootfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: home" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				homefs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: tmp" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				tmpfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: usr" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				usrfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: var" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				varfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: srv" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				srvfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: opt" 20 30 7 ${p} 2> temp
			part="$(cat temp)"
			rm temp
			# Option is selected
			if [ "$?" = "0" ]
			then
				optfs=$part
			fi

			fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"

			dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
				--menu "Choose the format that you want to use" 20 30 7 ${fs} 2> temp
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
			# fdisk -l "$disk" > /tmp/partitions
			# partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
			# p=$(echo $partitions)
			dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
				--menu "Choose the partition type that you want to use for: swap" 20 30 7 ${p} 2> temp
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