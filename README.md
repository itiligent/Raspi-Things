UBUNTU:

Optimised MMC configuration for Raspi UBUNTU. Apply to a fresh & default UBUNTU Raspi image!!

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-ubuntu.sh -O mmc-optimisation-ubuntu.sh && chmod +x mmc-optimisation-ubuntu.sh && sudo ./mmc-optimisation-ubuntu.sh

Optimaed USB SSD configuration for Raspi UBUNTU (Must be used on a fresh and prebuilt UBUNTU USB SSD ready image - see raspi-usb-boot-fix-ubuntu-20.4.sh)

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/usbssd-optimisation-ubuntu.sh -O usbssd-optimisation-ubuntu.sh && chmod +x usbssd-optimisation-ubuntu.sh && sudo ./usbssd-optimisation-ubuntu.sh


RASBIAN:

Optimised MMC configuration for RASPIAN. Apply to a fresh & default RASPIAN image!! 
 
    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-raspian.sh -O mmc-optimisation-raspian.sh && chmod +x mmc-optimisation-raspian.sh && sudo ./mmc-optimisation-raspian.sh

Optimised MMC configuration for RASPIAN. Apply to a fresh & default RASPIAN image!! (without experimental ZRAM) 

wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/mmc-optimisation-raspian.sh -O mmc-optimisation-raspian.sh && chmod +x mmc-optimisation-raspian.sh && sudo ./mmc-optimisation-raspian.sh


Optimised GENERAL configuration for RASPIAN - (add usb-storage-quirks for USB SSD)

    wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/general-optimisation-raspian.sh -O general-optimisation-raspian.sh && chmod +x general-optimisation-raspian.sh && sudo ./general-optimisation-raspian.sh
