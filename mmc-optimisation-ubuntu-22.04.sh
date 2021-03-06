#!/bin/bash
###################################################################################
# Build Ubuntu optimised for MMC cards - Extend MMC life on Raspi
# For Ubuntu 22.04
# David Harrop 
# June 2022
###################################################################################

clear

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

#Stop annoyong popups relating to service restarts and reboots (breaks the script running)
#sed -i 's/#$nrconf{kernelhints} = -1;/$nrconf{kernelhints} = 0;/' /etc/needrestart/needrestart.conf
#NEEDRESTART_MODE=a
#export NEEDRESTART_MODE=a

sudo apt-get update
DEBIAN_FRONTEND=noninteractive apt install zram-config linux-modules-extra-raspi raspi-config libraspberrypi-bin -y
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

sleep 3
echo 
echo -e "${YELLOW}Disabling a few defaults to speed things up...${NC}"
echo
# Disbale cloud init coz its a pain
sudo touch /etc/cloud/cloud-init.disabled

#Enable zswap for some performance boost!
sed -i s/$/' zswap.enabled=1'/ /boot/firmware/cmdline.txt

#Disable hardware items in /boot/firmware/usercfg.txt so save power and resources
echo 'dtoverlay=disable-wifi' | sudo tee -a /boot/firmware/usercfg.txt 
echo 'dtoverlay=disable-bt' | sudo tee -a /boot/firmware/usercfg.txt
echo 'dtparam=audio=off' | sudo tee -a /boot/firmware/usercfg.txt 

# Disable Avahi to save memory - cloud init annoyingly installs this on first boot 
# if you dont disable it before first connecting to the internet
sudo systemctl stop avahi-daemon.socket >/dev/null
sudo systemctl disable avahi-daemon.socket >/dev/null
sudo systemctl stop avahi-daemon.service >/dev/null
sudo systemctl disable avahi-daemon.service >/dev/null
sudo systemctl stop wpa_supplicant >/dev/null
sudo systemctl disable wpa_supplicant >/dev/null

# Set Swappiness changes the frequency the OS goes to the disk. 60 is Ubuntu default. 0 is not recommended
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf >/dev/null

sleep 3
echo 
echo -e "${YELLOW}Setting up timesync...${NC}"
echo
#Set time server
sudo cat <<EOF | sudo tee /etc/systemd/timesyncd.conf >/dev/null
[Time]
NTP=time.google.com time.windows.com
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
EOF

sleep 3
echo 
echo -e "${YELLOW}Modifying partitions for MMC longevity...${NC}"
echo
# MMC Reduce Wear
# For refernce, Ubuntu fpr raspi default fstab is:
#LABEL=writable  /        ext4   defaults        0 1
#LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

# Change fstab to support minimal disk timestamping and delay writes from RAM to every 30min, tweak if you like:
sudo sed -i 's/LABEL=writable/#LABEL=writable/g' /etc/fstab
echo -e 'LABEL=writable  /        ext4   noatime,errors=remount-ro,commit=1800,defaults        0 1' | sudo tee -a /etc/fstab >/dev/null

sleep 3
echo 
echo -e "${YELLOW}Setting up network...${NC}"
echo
## Uncomment the network config required, you can only choose one, or build your own
## Be super careful and dont mix tabs with spaces. Indents are critical. 
## A space in the wrong place = hell!
#Configured Defaults are DHCP ETH0 
sudo cat <<EOF | sudo tee /etc/netplan/50-cloud-init.yaml >/dev/null
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

sleep 3
echo 
echo -e "${YELLOW}Getting ready to install log2ram...${NC}"
echo
# Install Log2Ram so we can put all out log files into a ramdisk and dump them with one write once per day.
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg

sudo apt-get update 
DEBIAN_FRONTEND=noninteractive apt install log2ram
cp /etc/log2ram.conf /etc/log2ram.conf.bak
sudo cat <<EOF | sudo tee /etc/log2ram.conf >/dev/null
SIZE=192M
MAIL=true
PATH_DISK="/var/log"
ZL2R=false
COMP_ALG=lz4
LOG_DISK_SIZE=300M
EOF

cp /usr/bin/init-zram-swapping /usr/bin/init-zram-swapping.bak
#to restore...
#cat init-zram-swapping.bak | sudo tee init-zram-swapping
cat <<-"EOF"| sudo tee /usr/bin/init-zram-swapping
#!/bin/sh

modprobe zram

# Calculate memory to use for zram (1/4 of ram)
totalmem=`LC_ALL=C free | grep -e "^Mem:" | sed -e 's/^Mem: *//' -e 's/  *.*//'`
mem=$((totalmem / 4 * 1024))

# initialize the devices
echo zstd > /sys/block/zram0/comp_algorithm
echo $mem > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon -p 5 /dev/zram0

EOF
apt-get autoremove -y

printf "${GREEN}+---------------------------------------------------------------------------------------------------------------------------
+ You will need to reboot for Log2Ram and ZRAM changes to take effect. 
+---------------------------------------------------------------------------------------------------------------------------${NC}\n"
