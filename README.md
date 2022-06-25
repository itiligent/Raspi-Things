Preserve MMC life with this optimised configuration for Raspi Ubuntu. Apply to a default UBUNTU Raspi install image - not for Raspian!! 
    
Enhanments:
zswap memory managment enabled |
Enhanced partitioning removing all file access time disk writes. | 
All disk writes committed every 30 min |
Timesync set |
Netplan options for a second USB LTE NIC - inc routing metrics |
Log2Ram - customisable ramdrive for log files, ramdrive writes out logs to disk once daily. |
cloud-init , wifi, bluetooth, audio chip , avahi services disabled

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-ubuntu.sh -O mmc-optimisation-ubuntu.sh && chmod +x mmc-optimisation-ubuntu.sh && sudo ./mmc-optimisation-ubuntu.sh


For Ubuntu Raspi on USB SSD drive, similar tweaks without messing with partitions and log2ram. 

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/usbssd-optimisation-ubuntu.sh -O usbssd-optimisation-ubuntu.sh && chmod +x usbssd-optimisation-ubuntu.sh && sudo ./usbssd-optimisation-ubuntu.sh1
