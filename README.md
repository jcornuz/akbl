# AKBL: Automatic Keyboard BackLight service
 
- start typing and your keyboard backlight switches on
- stop typing and your keyboard backlight switches off (after a few seconds delay)
- the service is only active during selected hours (at night, for example!)

You can configure a few options in /etc/akbl.conf:
- active hours
- delay for switching off the backlight


The install.sh script installs the necessary files and service for AKBL

`main file: /usr/local/bin/akbl.sh 

config file: /etc/akbl.conf

(systemd) start / stop service file: /lib/systemd/system/akbl.service

(systemd) restart after resume service file: /lib/systemd/system/akbl-resume.service`


Ready to try? Download and extract zip file and run install.sh (as root)

> sudo ./install.sh -i (for installation)

> sudo ./install.sh -u (for uninstallation)

This works with Fedora on a T480s Laptop... so no guarantee it will work for you :/
