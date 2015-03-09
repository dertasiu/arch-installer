#!/bin/bash

##Basic welcome message
dialog --backtitle "ArchLinux Installation" --title "Welcome" --msgbox 'Proceed to the installation:' 6 30

##Keyboard type selcetion
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
                   --menu "Choose the partition type that you want to use for: boot" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
               part=$choice
               bootfs=$part
            #esac
         
            #Format the selected partition
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
        "/home")
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
                   --menu "Choose the partition type that you want to use for: home" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                part=$choice
                homefs=$part
            #esac
           #Format the selected partition
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
                parts="$parts"",home";;
            esac
        "/tmp")
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
                   --menu "Choose the partition type that you want to use for: tmp" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                part=$choice
                tmpfs=$part
            #esac
            
            #Format the selected partition
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
                parts="$parts"",tmp";;
            esac
        "/usr")
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
                   --menu "Choose the partition type that you want to use for: usr" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                part=$choice
                usrfs=$part
            #esac
           
            #Format the selected partition
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
                parts="$parts"",usr";;
            esac
        "/var")
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
                   --menu "Choose the partition type that you want to use for: var" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                part=$choice
                varfs=$part
            #esac
         
            #Format the selected partition
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
                parts="$parts"",var";;
            esac
        "/srv")
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
                   --menu "Choose the partition type that you want to use for: srv" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                part=$choice
                srvfs=$part
            #esac
           
            #Format the selected partition
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
                parts="$parts"",srv";;
            esac
        "/opt")
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
                   --menu "Choose the partition type that you want to use for: opt" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                part=$choice
                optfs=$part
            #esac
            
            #Format the selected partition
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
                parts="$parts"",opt";;
            esac
        "swap")
            #Make swap
            dialog --backtitle "ArchLinux Installation" --title "Disk Selection" --msgbox 'Now you are going to select and format the swap partition' 7 30
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
                   --menu "Choose the partition type that you want to use" 20 30 7 \
                   ${p} 2> $tempfile
            retval=$?
            choice=`cat $tempfile`
            case $retval in
              0)
                mkswap $choice
                swapon $choice;;
            esac
    esac
done

parts="$(echo $parts | sed 's/^..//')"

##Mounts
mkdir -p /mnt/{$parts}
mount $rootfs /mnt
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