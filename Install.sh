#!/bin/bash

##Basic welcome message
dialog --backtitle "ArchLinux Installation" --title "Welcome" --msgbox 'Proceed to the installation:' 6 30

##Keyboard type selection
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
localectl list-keymaps > /tmp/original
locales2="$(awk '$locales=$locales" Keyboard"' /tmp/original)" #Save a list of all keymap files available to locales2 variable processing a 2ª column to make the menu
dialog --backtitle "ArchLinux Installation" --clear --title "Choose your keymap: " \
       --menu "Hi! Choose your favorite keymap:" 20 51 7 \
       ${locales2} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
  0)
    loadkeys $choice #Loads the selected keymap
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
       --menu "Choose the Hard Drive that you want to use" 20 30 7 \
       ${part} 2> $tempfile
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
       --menu "Choose the partition type that you want to use for: /" 20 30 7 \
       ${p} 2> $tempfile
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
       --menu "Choose the partition type that you want to use" 20 30 7 \
       ${fs} 2> $tempfile
retval=$?
choice=`cat $tempfile`
case $retval in
  0)
    mkfs.$choice $part
    parts="$parts"",boot";;
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
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: boot" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                bootfs=$part
            fi
            
            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                bootdir="boot"
            fi
            ;;
        "/home")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: home" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                homefs=$part
            fi
            
            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                homedir="home"
            fi
            ;;
        "/tmp")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: tmp" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                tmpfs=$part
            fi
            
            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                tmpdir="tmp"
            fi
            ;;
        "/usr")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: usr" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                usrfs=$part
            fi
            
            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                usrdir="usr"
            fi
            ;;
        "/var")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: var" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                varfs=$part
            fi
            
            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                vardir="var"
            fi
            ;;
        "/srv")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: srv" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                srvfs=$part
            fi
            
            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                srvdir="srv"
            fi
            ;;
        "/opt")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: opt" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                optfs=$part
            fi

            fs="$(ls /bin/* | grep mkfs | awk '{if (NR!=1) {print}}' | sed 's/^.\{10\}//g' | awk '{print substr($0, 0, length($0)-0)}' | awk '$fs=$fs" Type"' |  awk '{if (NR!=1) {print}}')"
            
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition type: " \
                   --menu "Choose the format that you want to use" 20 30 7 \
                   ${fs} 2> temp
            filesystem="$(cat temp)"
            rm temp
            if [ "$?" = "0" ]
            then
                mkfs.$filesystem $part
                optdir="opt"
            fi
            ;;
        "swap")
            fdisk -l "$disk"
            echo "You can press Shift + PageUp/PageDown to scroll"
            read -p "Press Return to continue..."
            fdisk -l "$disk" > /tmp/partitions
            partitions="$(cat /tmp/partitions | grep sd | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1,$5}')"
            p="$(echo "$partitions")"
            dialog --backtitle "ArchLinux Installation" --clear --title "Partition selection: " \
                   --menu "Choose the partition type that you want to use for: swap" 20 30 7 \
                   ${p} 2> temp
            part="$(cat temp)"
            rm temp
            # Option is selected
            if [ "$?" = "0" ]
            then
                mkswap $part
                swapon $part
            fi
    esac
done

parts="$(echo $parts | sed 's/^..//')"

##Mounts
mount $rootfs /mnt
mkdir -p /mnt/{$bootfs,$homefs,$tmpfs,$usrfs,$varfs,$srvfs,$optfs}
mount $bootfs /mnt/boot
mount $homefs /mnt/home
mount $tmpfs /mnt/tmp
mount $usrfs /mnt/usr
mount $varfs /mnt/var
mount $srvfs /mnt/srv
mount $optfs /mnt/opt

##Install basic system
pacstrap /mnt base base-devel grub-bios networkmanager os-prober

##Generate the fstab file
genfstab /mnt > /mnt/etc/fstab

##Generate the chroot script
#Select the locale
locales="$(cat /mnt/etc/locale.gen | grep _ | sed '1,4d' | sed 's/\(.\{1\}\)//')"

dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
                   --menu "Choose your language" 20 30 7 \
                   ${locales} 2> temp
locale="$(cat temp)"
rm temp
if [ "$?" = "0" ]
then
    sed -i "/${locale}/ s/# *//" /etc/locale.gen
fi

#Select and generate the locale
locales="$(cat /mnt/etc/locale.gen | grep _ | sed '/#/d')"
dialog --backtitle "ArchLinux Installation" --clear --title "Locale selection: " \
                   --menu "Choose your language" 20 30 7 \
                   ${locales} 2> temp
locale="$(cat temp)"
rm temp
if [ "$?" = "0" ]
then
    echo $locale > /etc/locale.conf
fi
#Testing