#!/bin/bash
# Physical Power Button and LED Install instructions:
# Connect switch to GPIO Pin3 and GND
# Optional power led:
# 330 ohm resistor
# 2-5v led
# Connect led + to TXD Pin8
# Connect led - to GND Pin6

# download and install the scripts 
wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/listen-for-shutdown.py -O listen-for-shutdown.py
wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/listen-for-shutdown.sh -O listen-for-shutdown.sh
mv listen-for-shutdown.py /usr/local/bin/
chmod +x /usr/local/bin/listen-for-shutdown.py
update-rc.d listen-for-shutdown.sh defaults
/etc/init.d/listen-for-shutdown.sh start

# Enable serial gpio for Led power - Are we installing to Raspbian or Ubuntu?
source /etc/os-release
if [[ $PRETTY_NAME = "bullseye" ]] || [[ $PRETTY_NAME = "buster" ]]; then
sed -i s/$/' enable_uart=1'/ /boot/cmdline.txt
else
sed -i s/$/' enable_uart=1'/ /boot/firmware/cmdline.txt
fi
