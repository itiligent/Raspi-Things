#!/bin/bash
###################################################################################
# Build Ubuntu optimised for MMC cards - Extend MMC life on Raspi
# For Raspian 
# David Harrop 
# June 2022
###################################################################################

clear

YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color

############################ Univerasl fixes: ###########################################

sleep 2
echo 
echo -e "${YELLOW}Disabling a few defaults and speedings things up...${NC}"
echo

#enable ssh the easy way
touch /boot/sh

#Disable hardware items in /boot/firmware/usercfg.txt so save power and resources
echo 'dtoverlay=disable-wifi' | sudo tee -a /boot/config.txt 
echo 'dtoverlay=disable-bt' | sudo tee -a /boot/config.txt
sudo sed -i  '$ a gpu_mem=16' /boot/config.txt
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
sudo systemctl disable triggerhappy >/dev/null
sudo systemctl stop triggerhappy >/dev/null
sudo /etc/init.d/alsa-utils stop >/dev/null
sudo /etc/init.d/alsa-utils disable >/dev/null

#Stop drivers being loaded and taking up memory/power
cat > /etc/modprobe.d/raspi-blacklist.conf <<EOF
# WiFi
blacklist brcmfmac
blacklist brcmutil

# Bluetooth
blacklist btbcm
blacklist hci_uart
EOF

# Set locales to AU - adjust as needed
sudo sed -i "s/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/g" /etc/locale.gen
sudo sed -i "s/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/g" /etc/locale.gen
sudo locale-gen
sudo timedatectl set-timezone Australia/Melbourne

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


############################ MMC oriented fixes: ###########################################

# Set Swappiness changes the frequency the OS goes to the disk. 60 is Ubuntu default. 0 is not recommended
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf >/dev/null

sleep 2
echo 
echo -e "${YELLOW}Modifying partitions for MMC performance...${NC}"
echo
# MMC Reduce Wear
# For refernce, Ubuntu fpr raspi default fstab is:
#LABEL=writable  /        ext4   defaults        0 1
#LABEL=system-boot       /boot/firmware  vfat    defaults        0       1

# Change fstab to support journal writes from RAM every 30min, tweak if you like:
sudo sed -i 's/defaults,noatime/defaults,noatime,commit=1800/g' /etc/fstab

sleep 2
echo 
echo -e "${YELLOW}Getting ready to install log2ram...${NC}"
echo
# Install Log2Ram so we can put all out log files into a ramdisk and dump them with one write once per day.
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
sudo apt update 
sudo apt install log2ram -y
cp /etc/log2ram.conf /etc/log2ram.conf.bak
sudo cat <<EOF | sudo tee /etc/log2ram.conf >/dev/null
SIZE=192M
MAIL=true
#PATH_DISK="/var/log";"/opt/gvm/var/log"
PATH_DISK="/var/log"
ZL2R=false
COMP_ALG=lz4
LOG_DISK_SIZE=300M
EOF
sudo systemctl restart console-setup.service
	
printf "${RED}+---------------------------------------------------------------------------------------------------------------------------
+ You will need to reboot for Log2Ram changes to take effect. 
+---------------------------------------------------------------------------------------------------------------------------${NC}\n"

############################ Experimental Performance oriented fixes: ###########################################

sleep 2
echo 
echo -e "${YELLOW}Getting ready to install ZRAM...${NC}"
echo

#define error, status and status_green functions in case this script is being run standalone without pi-apps api (wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/apps/More%20RAM/install | bash)
error() { #red text and exit 1
  echo -e "\e[91m$1\e[0m" 1>&2
  exit 1
}
status() { #cyan text to indicate what is happening
  
  #detect if a flag was passed, and if so, pass it on to the echo command
  if [[ "$1" == '-'* ]] && [ ! -z "$2" ];then
    echo -e $1 "\e[96m$2\e[0m" 1>&2
  else
    echo -e "\e[96m$1\e[0m" 1>&2
  fi
}
status_green() { #announce the success of a major action
  echo -e "\e[92m$1\e[0m" 1>&2
}

set_value() { #Add the $1 line to the $2 config file. (setting=value format) This function changes the setting if it's already there.
  local file="$2"
  [ -z "$file" ] && error "set_value: path to config-file must be specified."
  [ ! -f "$file" ] && error "Config file '$file' does not exist!"
  local setting="$1"
  
  #This function assumes a setting=value format. Remove the number value to be able to change it.
  local setting_without_value="$(echo "$setting" | awk -F= '{print $1}')"
  
  #edit the config file with the new value
  sudo sed -i "s/^${setting_without_value}=.*/${setting}/g" "$file"
  
  #ensure sed actually did something; if not, add setting to end of file
  if ! grep -qxF "$setting" "$file" ;then
    echo "$setting" | sudo tee -a "$file" >/dev/null
  fi
}

set_sysctl_value() { #Change a setting for sysctl. Displays value, changes config file, and sets the value immediately.
  set_value "$1" /etc/sysctl.conf
  echo "  - $1"
  sudo sysctl "$1" >/dev/null
}

#disable dphys-swapfile service if running
if [ -f /usr/sbin/dphys-swapfile ] && systemctl is-active --quiet dphys-swapfile.service ;then
  status "Disabling swap"
  #swapoff and remove swapfile
  sudo /usr/sbin/dphys-swapfile uninstall
  
  #prevent dphys-swapfile from running on boot
  sudo systemctl mask dphys-swapfile.service #see /lib/systemd/system/dphys-swapfile.service
fi

#Disable Ubuntu's mkswap service if running
if systemctl is-active --quiet mkswap.service ;then
  status "Disabling swap"
  #swapoff and remove swapfile
  sudo systemctl disable mkswap.service
  
  #prevent dphys-swapfile from running on boot
  sudo systemctl mask mkswap.service
fi

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

status -n "Checking system for compatibility... "
if [ "$(ps --no-headers -o comm 1)" != systemd ];then
  error "\nUser error: Incompatible because your system was not booted with systemd."
elif ! command -v zramctl >/dev/null ;then
  error "\nUser error: Incompatible because the 'zramctl' command is missing on your system."
elif ! command -v swapon >/dev/null ;then
  error "\nUser error: Incompatible because the 'swapon' command is missing on your system."
elif ! command -v swapoff >/dev/null ;then
  error "\nUser error: Incompatible because the 'swapoff' command is missing on your system."
elif ! command -v modprobe >/dev/null ;then
  error "\nUser error: Incompatible because the 'modprobe' command is missing on your system."
elif ! sudo modprobe zram &>/dev/null ;then
  error "\nUser error: Incompatible because the 'zram' kernel module is missing on your system."
fi
status_green "Done"

status "Creating zram script: /usr/bin/zram.sh"
echo '#!/bin/bash

export LANG=C
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

if [ "$1" == --help ] || [ "$1" == -h ];then
  echo -e "This is a script made by Botspot to increase usable RAM by setting up ZRAM.
ZRAM uses compression to fit more memory in your available RAM.
This script will setup a ZRAM swapspace that is 4 times larger than usable RAM.
It also configures high-speed RAM-based file-storage at /zram.

Usage:

sudo zram.sh               Setup zram-swap and storage (if enabled)
sudo zram.sh stop          Disable all ZRAM devices and exit
sudo zram.sh storage-off   Disable the file-storage at /zram on next run
sudo zram.sh storage-on    Enable the file-storage at /zram on next run
zram.sh --help, -h         Display this information and exit"
  exit 0
fi


if [ $(id -u) -ne 0 ]; then
  echo "$0 must be run as root user"
  exit 1
fi

#avoid creating /zram storage if storage-off flag passed
if [ "$1" == storage-off ]; then
  #retain this flag for next boot
  if ! grep -qxF "ExecStart=/usr/bin/zram.sh storage-off" /etc/systemd/system/zram-swap.service ;then
    sed -i "s+^ExecStart=/usr/bin/zram.sh$+ExecStart=/usr/bin/zram.sh storage-off+g" /etc/systemd/system/zram-swap.service
  fi
  echo -e "zram.sh will not set up file-storage at /zram from now on."
#the /zram storage can be re-enabled with storage-on flag
elif [ "$1" == storage-on ]; then
  sed -i "s+^ExecStart=/usr/bin/zram.sh storage-off$+ExecStart=/usr/bin/zram.sh+g" /etc/systemd/system/zram-swap.service
  echo -e "zram.sh will set up file-storage at /zram from now on."
fi

# Load zram module
if ! modprobe zram ;then
  echo "Failed to load zram kernel module"
  exit 1
fi

# disable all zram devices
echo -n "Disabling zram... "
IFS=$'\''\n'\''
for device_number in $(find /dev/ -name zram* -type b | tr -cd "0123456789\n") ;do
  #if zram device is a swap device, disable it
  swapoff /dev/zram${device_number} 2>/dev/null
  
  #if zram device is mounted, unmount it
  umount /dev/zram${device_number} 2>/dev/null
  
  #remove device
  echo $device_number >/sys/class/zram-control/hot_remove
done
echo Done

rm -rf /zram

#exit script now if "exit" flag passed
if [ "$1" == stop ]; then
  exit 0
fi

#create new zram drive - for swap
drive_num=$(cat /sys/class/zram-control/hot_add)

# use zstd compression if available - best option according to https://linuxreviews.org/Comparison_of_Compression_Algorithms#zram_block_drive_compression
if cat /sys/block/zram${drive_num}/comp_algorithm | grep -q zstd ;then
  algorithm=zstd
else
  algorithm=lz4
fi
echo $algorithm > /sys/block/zram${drive_num}/comp_algorithm

totalmem=$(free | grep -e "^Mem:" | awk '\''{print $2}'\'')

#create zram disk 4 times larger than usable RAM - compression ratio for zstd can approach 5:1 according to https://linuxreviews.org/Zram
echo $((totalmem * 1024 * 4)) > /sys/block/zram${drive_num}/disksize

#make the swap device (by default this will be /dev/zram0)
mkswap /dev/zram${drive_num}
swapon /dev/zram${drive_num} -d -p 1

#create second zram drive: for temporary user-storage at /zram
if ! grep -qxF "ExecStart=/usr/bin/zram.sh storage-off" /etc/systemd/system/zram-swap.service ;then
  echo "Setting up ZRAM-powered file storage at /zram"
  #create new zram drive
  drive_num=$(cat /sys/class/zram-control/hot_add)
  
  # set compression algorithm
  echo $algorithm > /sys/block/zram${drive_num}/comp_algorithm
  
  #set the size of drive to be 4 times the available RAM
  echo $((totalmem * 1024 * 4)) > /sys/block/zram${drive_num}/disksize
  
  #create a partition and mount it
  mkfs.ext4 /dev/zram${drive_num} >/dev/null
  mkdir -p /zram
  mount /dev/zram${drive_num} /zram
  chmod -R 777 /zram #make writable for any user
fi' | sudo tee /usr/bin/zram.sh >/dev/null

sudo chmod +x /usr/bin/zram.sh

status "Making it run on startup"
echo '  - Creating zram-swap.service'
echo '[Unit]
Description=Configures zram swap device
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/bin/zram.sh
ExecStop=/usr/bin/zram.sh stop
RemainAfterExit=yes

[Install]
WantedBy = multi-user.target' | sudo tee /etc/systemd/system/zram-swap.service >/dev/null
echo '  - Reloading Systemd unit files'
sudo systemctl daemon-reload
echo '  - Enabling zram-swap.service to run on boot'
sudo systemctl enable zram-swap.service

status -n "Running it now."
echo " Output:"
sudo /usr/bin/zram.sh || exit 1

status "Changing kernel parameters for better performance:"
#change kernel values as recommended by: https://haydenjames.io/linux-performance-almost-always-add-swap-part2-zram
set_sysctl_value vm.swappiness=100
set_sysctl_value vm.vfs_cache_pressure=500
set_sysctl_value vm.dirty_background_ratio=1
set_sysctl_value vm.dirty_ratio=50

echo
status_green "ZRAM should now be set up. Consider rebooting your device."

status "Below is a summary:"
zramctl
status "You can see this at any time by running 'zramctl'"
sleep 1


