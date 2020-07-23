#!/bin/bash

# get configuration file
source /etc/akbl.conf


# check for root user
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi


# INIT VARIABLES

counter=1
light_status=off

# polling time in seconds
polling_time_s=$(bc <<< "scale=1;$polling_time  / 10")

# how many counter to wait for the correct(ish) off_time
off_time_counter=$(bc <<< "scale=0; (1 / $polling_time_s ) * $off_time")

# getting the keyboard (hopefully)
#keyboard="/dev/input/event3"

if [ ! -c "$keyboard" ]; then
    echo "Sorry I couln't find a keyboard input"
    exit 1
fi


# Systemd service stuff
DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Automatic Keyboard BackLight Service started at ${DATE}" | systemd-cat -p info


# getting the backlight class (hopefully)
backlight=$(find /sys/class | grep kbd_backlight)
backlight="${backlight}/brightness"

if [ ! -f "$backlight" ]; then
    echo "Sorry I couln't find a backlight switch"
    exit 1
fi


while true; do

    current_time=$(date +%H:%M)
    
    if [[ "$current_time" > "$startup_time" ]] || [[ "$current_time" < "$end_time" ]]; then        
        # get input from keyboard
        POLL=$(timeout $polling_time_s cat $keyboard)
    
        # keyboard is active, switch lights on
        if [ "$POLL" ]; then
            counter=1
            if [ "$light_status" == "off" ]; then
                echo "switching lights on"
                echo $on_value > $backlight
                light_status="on"
            fi    
            
        # keyboard is inactive... if it stays so for off_time, switch lights off
        else
            if [ "$counter" -lt "$off_time_counter" ]; then
                counter=$((counter + 1))
            elif [ "$counter" -eq "$off_time_counter" ]; then
                if [ "$light_status" == "on" ]; then
                    echo "switching lights off"
                    echo $off_value > $backlight
                    light_status="off"
                fi
            fi
        fi
    
    else
        # outside active hours, sleep until starup time
        echo "sleep until $startup_time"
        sleep $(( $(date +%s -d "today $startup_time") - $(date +%s) ))

	#sleep for 10 minutes
#	echo "outside active hours: sleep for 10 mins"
#	sleep 600
    fi
done
