#!/bin/bash

Help() {

    echo ""
    echo "AKBL is an Automatic Keyboard BackLight service: "
    echo "start typing and your keyboard backlight switches on"
    echo "stop typing and your keyboard backlight switches off (after a few seconds delay)"
    echo ""
    echo "This script installs the necessary files for AKBL service,"
    echo "You can configure a few options by editing /etc/akbl.conf"
    echo ""
    echo "The options of this script are"
    echo "-i for install"
    echo "-u for uninstall"
    echo ""
}


Uninstall() {
    
    # check for root user
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi

    echo "This will uninstall AKBL"
    echo "Is that OK? (y / n)"
    
    read answer
    
    if [ "$answer" != "y" ]; then
        echo "exiting..."
        exit 1;
    fi

    echo ""
    echo "Stopping and disabling services"
    
    systemctl disable akbl
    systemctl disable akbl-resume
    systemctl stop akbl
    systemctl stop akbl-resume

    echo ""
    echo "Removing files"
    rm /etc/akbl.conf
    rm /lib/systemd/system/akbl.service
    rm /lib/systemd/system/akbl-resume.service
    rm /usr/local/bin/akbl.sh
    
    echo ""
    echo "All done, thank you for using AKBL"
}


Install() {

    # check for root user
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
    
    echo "Installing Automatic Keyboard BackLight (AKBL) service"
    echo "Is that OK? (y / n)"
    
    read answer
    
    if [ "$answer" != "y" ]; then
        echo "exiting..."
        exit 1;
    fi
    
    echo "Copying files..."
    echo ""
    
    cp akbl.conf /etc/akbl.conf
    cp akbl.service /lib/systemd/system/akbl.service
    cp akbl-resume.service /lib/systemd/system/akbl-resume.service
    cp akbl.sh /usr/local/bin/akbl.sh
    
    
    echo "Detecting keyboard"
    
    keyboard=`/usr/bin/xinput list --id-only "Virtual core keyboard" `
    keyboard="/dev/input/event${keyboard}"
    
    if [ ! -c "$keyboard" ]; then
        echo "Sorry couln't find a keyboard input"
        exit 1
    else
        echo "Keyboard dected: $keyboard"
        echo "and added to /etc/akbl.conf file (you can change it there later if required)"
    fi
    
    echo ""
    
    printf "\n\n#keyboard detected at install\nkeyboard=$keyboard" >> /etc/akbl.conf
    
    echo "Enabling services: akbl and akbl-resume"
    
    systemctl enable akbl
    systemctl enable akbl-resume
    systemctl start akbl
    systemctl start akbl-resume
    
    echo "All done... enjoy"
    echo ""
    echo "You can configure options in /etc/akbl.conf"
}


case "$1" in
  "-i")
    Install
    ;;
  "-u")
    Uninstall
    ;;
  *)
    Help
    exit 1
    ;;
esac
