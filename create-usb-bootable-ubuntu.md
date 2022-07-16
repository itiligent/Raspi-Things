        ##USB HDD & UBUNTU Instructions
      

1. Boot your Raspi via a MMC card running Raspian 

2. Image your SSD with a Ubuntu image using your preferred imaging tool 

3. plug the SSD into a USB2 port

4. lsblk

Output of lsblk shows the SSD device, in this case it is sda1 and sda2 
 
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0 119.2G  0 disk 
├─sda1        8:1    0   256M  0 part 
└─sda2        8:2    0   2.8G  0 part 
mmcblk0     179:0    0  59.5G  0 disk 
├─mmcblk0p1 179:1    0   256M  0 part /boot
└─mmcblk0p2 179:2    0  59.2G  0 part /


5. Adjust the below commands according to the lsblk output (sda1 and sda2 may be different)

sudo mkdir /mnt/boot
sudo mkdir /mnt/writable
sudo mount /dev/sda1 /mnt/boot
sudo mount /dev/sda2 /mnt/writable

6. lsblk once again...

NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0 119.2G  0 disk 
├─sda1        8:1    0   256M  0 part /mnt/boot
└─sda2        8:2    0   2.8G  0 part /mnt/writable
mmcblk0     179:0    0  59.5G  0 disk 
├─mmcblk0p1 179:1    0   256M  0 part /boot
└─mmcblk0p2 179:2    0  59.2G  0 part /

7. Now run the script:

wget https://github.com/itiligent/Raspi-Things/blob/main/create-usb-bootable-ubuntu.sh -O create-usb-bootable-ubuntu.sh && chmod +x create-usb-bootable-ubuntu.sh && sudo ./create-usb-bootable-ubuntu.sh
