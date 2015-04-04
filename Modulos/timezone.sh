#Select the timezone
eleccion=0
timezones="$(ls -l /usr/share/zoneinfo | grep -v .tab | awk -F " " '{print $9}' | awk '$fs=$fs" Time"')"
dialog --backtitle "ArchLinux Installation" --clear --title "Timezone selection: " \
        --menu "Choose your timezone" 20 30 7 ${timezones} 2> temp
timezone="$(cat temp)"
rm temp
#if [ "$?" = "0" ]
#then
#        if [ $eleccion = "0" ]
#        then
#                if test -f $timezone; then
#                        ln -s $timezone timezone >&2
#			eleccion=1
#                else
#                        cd /usr/share/zoneinfo/$timezone >&2
#                fi
#	fi
#fi
