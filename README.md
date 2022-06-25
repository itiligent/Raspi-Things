Preserve MMC lifewith this optimised configuration for Raspi Ubuntu. Apply to a default UBUNTU Raspi install image - not for Raspian!! 
    
Enhanments:
zswap memory managment enabled
Enhanced partitioning removing all file access time disk writes. 
All disk writes committed every 30 min
Timesync set
Netplan options for a second USB LTE NIC - inc routing metrics
Log2Ram - customisable ramdrive for log files, writes out logs to disk once daily.
cloud-init , wifi, bluetooth, audio chip , avahi services disabled

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-raspi-ubuntu.sh -O mmc-optimisation-raspi-ubuntu.sh && chmod +x mmc-optimisation-raspi-ubuntu.sh && sudo ./mmc-optimisation-raspi-ubuntu.sh
