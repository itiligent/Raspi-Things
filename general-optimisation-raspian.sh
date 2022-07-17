#!/bin/bash
###################################################################################
# Build Raspian from default factory image - General base settings
# # David Harrop 
# June 2022
###################################################################################

clear
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

############################ Univerasl fixes: ##########################################
sudo apt-get update
sudo apt-get upgrade -y

sleep 2
echo 
echo -e "${YELLOW}Disabling a few defaults and speedings things up...${NC}"
echo

#enable ssh the easy way
touch /boot/sh

#Disable hardware items in /boot/firmware/usercfg.txt so save power and resources
sed -i '/Additional overlays and parameters/a dtoverlay=disable-wifi' /boot/config.txt
sed -i '/Additional overlays and parameters/a dtoverlay=disable-bt' /boot/config.txt
sed -i  '$ a gpu_mem=16' /boot/config.txt
sed -i 's/dtparam=audio=on/dtparam=audio=off/g' /boot/config.txt
sed -i '/console/a #USB SSD boot - run lsusb, then add lsusb device output code ????:???? at the start of the above line formatted as: usb-storage.quirks=????:????:u' /boot/cmdline.txt

# Disable services we dont want
sudo systemctl stop avahi-daemon.socket >/dev/null
sudo systemctl disable avahi-daemon.socket >/dev/null
sudo systemctl stop avahi-daemon.service >/dev/null
sudo systemctl disable avahi-daemon.service >/dev/null
sudo systemctl stop wpa_supplicant >/dev/null
sudo systemctl disable wpa_supplicant >/dev/null
sudo systemctl disable bluetooth >/dev/null
sudo systemctl stop bluetooth >/dev/null
sudo systemctl stop triggerhappy.socket >/dev/null
sudo systemctl disable triggerhappy.socket >/dev/null
sudo systemctl stop triggerhappy >/dev/null
sudo systemctl disable triggerhappy >/dev/null


#Stop drivers being loaded and taking up memory/power
cat > /etc/modprobe.d/raspi-blacklist.conf <<EOF
# WiFi
blacklist brcmfmac
blacklist brcmutil

# Bluetooth
blacklist btbcm
blacklist hci_uart

#Sound
blacklist snd_bcm2835
EOF

# Set locales to AU - adjust as needed
locale="en_AU.UTF-8 UTF-8"
#sudo sed -i "s/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g" /etc/locale.gen
sudo sed -i "s/# $locale/$locale/g" /etc/locale.gen
sudo locale-gen $locale
sudo update-locale $locale

sleep 2
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

apt-get autoremove -y
