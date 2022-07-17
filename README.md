## RASPBERRY PI OS CONFIG SCRIPTS

MMC LONGEVITY RASPIAN 
 
    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-raspian.sh -O mmc-optimisation-raspian.sh && chmod +x mmc-optimisation-raspian.sh && sudo ./mmc-optimisation-raspian.sh



GENERAL RASPIAN (Please see "usb-storage-quirks" for some USB3.0 SSD devices)

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/general-optimisation-raspian.sh -O general-optimisation-raspian.sh && chmod +x general-optimisation-raspian.sh && sudo ./general-optimisation-raspian.sh



## UBUNTU SERVER FOR RASPI CONFIG SCRIPTS

MMC LONGEVITY UBUNTU 22.04 

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-ubuntu-22.04.sh -O mmc-optimisation-ubuntu-22.04.sh && chmod +x mmc-optimisation-ubuntu-22.04.sh && sudo ./mmc-optimisation-ubuntu-22.04.sh  


MMC LONGEVITY UBUNTU 20.04.4. 

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-ubuntu-20.04.sh -O mmc-optimisation-ubuntu-20.04.sh && chmod +x mmc-optimisation-ubuntu-20.04.sh && sudo ./mmc-optimisation-ubuntu-20.04.sh    
    


USB HDD UBUNTU 22.04 (22.04 natively supports USB boot)

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/general-optimisation-ubuntu-22.04.sh -O general-optimisation-ubuntu-22.04.sh && chmod +x general-optimisation-ubuntu-22.04.sh && sudo ./general-optimisation-ubuntu-22.04.sh


    
USB HDD UBUNTU 20.04.4 (Requires decompressed kernel image - see create-usb-bootable-ubuntu.sh)

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/general-optimisation-ubuntu-20.04.sh -O general-optimisation-ubuntu-20.04.sh && chmod +x general-optimisation-ubuntu-20.04.sh && sudo ./general-optimisation-ubuntu-20.04.sh


## Enable Raspi Physcial Shutdown Button & Power LED

     wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/setup-raspi-power-button.sh -O setup-raspi-power-button.sh && chmod +x setup-raspi-power-button.sh && sudo ./setup-raspi-power-button.sh

