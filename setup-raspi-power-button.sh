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

# Enable serial gpio for Led power - Are we installing to Raspbian or Ubuntu?
source /etc/os-release
if [[ $ID = "debian" ]] || [[ $ID = "some other" ]]; then

sed -i  '$ a enable_uart=1' /boot/config.txt
mv listen-for-shutdown.py /usr/local/bin/
mv listen-for-shutdown.sh /etc/init.d/
chmod +x /usr/local/bin/listen-for-shutdown.py
chmod +x /etc/init.d/listen-for-shutdown.sh
update-rc.d listen-for-shutdown.sh defaults
/etc/init.d/listen-for-shutdown.sh start

else

sed -i  '$ a enable_uart=1' /boot/firmware/config.txt
sudo apt-get update
sudo apt-get install python3-rpi.gpio
sudo ln -s /usr/bin/python3 /usr/bin/python
mv listen-for-shutdown.py /usr/local/bin/
mv listen-for-shutdown.sh /etc/init.d/
chmod +x /usr/local/bin/listen-for-shutdown.py
chmod +x /etc/init.d/listen-for-shutdown.sh
update-rc.d listen-for-shutdown.sh defaults
/etc/init.d/listen-for-shutdown.sh start

fi

#cleanup
rm setup-raspi-power-button.sh
