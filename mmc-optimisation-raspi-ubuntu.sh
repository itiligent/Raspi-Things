#!/bin/bash
###################################################################################
# Build Ubuntu optimised for MMC cards - Extend MMC life on Raspi
# For Ubuntu 20.04.4 (For Ubuntu USB/SSD optimised configs, see separate scripts)
# David Harrop 
# June 2022
###################################################################################

#Run these first from the console before connection the new image online, else 
# Ubuntu auto updates take over and you may not be able to run the script 
# until all updates are done, which can be ages.
#
# Before connection to internet:
# 	sudo touch /etc/cloud/cloud-init.disabled
# 	reboot, then
#   systemctl stop apt-daily.timer
# 	systemctl stop apt-daily-upgrade.timer
# Now connect to internet
# Download and run this script

clear

# Disbale cloud init coz its a pain
sudo touch /etc/cloud/cloud-init.disabled

#Enable zswap for some performance boost!
sed -i s/$/' zswap.enabled=1'/ /boot/firmware/cmdline.txt

#Disable hardware items in /boot/firmware/usercfg.txt so save power and resources
echo 'dtoverlay=disable-wifi' | sudo tee -a /boot/firmware/usercfg.txt
echo 'dtoverlay=disable-bt' | sudo tee -a /boot/firmware/usercfg.txt
echo 'dtparam=audio=off' | sudo tee -a /boot/firmware/usercfg.txt

#Set time server
sudo cat <<EOF | sudo tee /etc/systemd/timesyncd.conf
[Time]
NTP=time.google.com time.windows.com
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
EOF

# Disable Avahi to save memory - cloud init annoyingly installs this on first boot 
# if you dont disable it before first connecting to the internet
sudo systemctl stop avahi-daemon.service
sudo systemctl disable avahi-daemon.service
sudo systemctl stop avahi-daemon.socket
sudo systemctl disable avahi-daemon.socket

# MMC Reduce Wear
# For refernce, Ubuntu fpr raspi default fstab is:
#LABEL=writable  /        ext4   defaults        0 1
#LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

# Change fstab to support minimal disk timestamping and delay writes from RAM to every 30min, tweak if you like:
sudo sed -i 's/LABEL=writable/#LABEL=writable/g' /etc/fstab
echo -e 'LABEL=writable  /        ext4   noatime,errors=remount-ro,commit=1800,defaults        0 1' | sudo tee -a /etc/fstab

# Set Swappiness changes the frequency the OS goes to the disk. 60 is Ubuntu default. 0 is not recommended
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Install Log2Ram so we can put all out log files into a ramdisk and dump them with one write once per day.
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg

## Uncomment the network config required, you can only choose one, or build your own
## Be super careful and dont mix tabs with spaces. Indents are critical. 
## A space in the wrong place = hell!
#Configured Defaults are DHCP ETH0 
sudo cat <<EOF | sudo tee /etc/netplan/50-cloud-init.yaml
# Uncomment your preferred example configuration
# Be SUPER CAREFUL to keep the exact spacing and formatting
# DO NOT mix tabs and spaces. Indents are critical.
network:
    version: 2
    ethernets:
        eth0:
            optional: true
            dhcp4: true

#Configure STATIC ETH0 			
#network:
#    version: 2
#    ethernets:
#        eth0:
#            optional: true
#            dhcp4: false
#            addresses: [172.17.18.50/24]
#            gateway4: 172.17.18.1
#            nameservers:
#              addresses: [172.17.18.1,172.17.18.2]

#Configure STATIC ETH0 Plus secondary USB LTE
#network:
#    version: 2
#    ethernets:
#        eth0:
#            optional: true
#            dhcp4: true
#
#        usb0:
#            optional: true
#            dhcp4: true
#            dhcp4-overrides:
#              route-metric: 1000
EOF

# Generate and apply the chosen network config
sudo netplan generate
sudo netplan apply

# Now upgrade everything 
# sudo apt update && sudo apt upgrade -y

# Lets also install net-tools so it feels like Raspian 
sudo apt update && sudo install net-tools log2ram -y

cp /etc/log2ram.conf /etc/log2ram.conf.bak
sudo cat <<EOF | sudo tee /etc/log2ram.conf
SIZE=256M
MAIL=true
#PATH_DISK="/var/log";"/opt/gvm/var/log"
PATH_DISK="/var/log"
ZL2R=false
COMP_ALG=lz4
LOG_DISK_SIZE=400M
EOF


		
printf "+---------------------------------------------------------------------------------------------------------------------------
+ You will need to reboot for Log2Ram changes to take effect. 
+---------------------------------------------------------------------------------------------------------------------------\n"