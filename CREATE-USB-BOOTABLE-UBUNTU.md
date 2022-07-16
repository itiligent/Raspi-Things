   ## Create a USB bootable Ubuntu Raspberry Pi Image: ##
  
  
  
  
1. Image your SSD with a Ubuntu image using your preferred imaging tool. (**IMAGE MUST HAVE NEVER BEEN PREVIOUSY BOOTED**) 


2. Boot your Raspberry Pi via an MMC card running Raspian 


3. Important: plug the SSD into a **USB2.0** port. 


4. lsblk

        Output of lsblk shows the SSD device, in this case it is sda1 and sda2 
 
        NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        sda           8:0    0 119.2G  0 disk 
        ├─sda1        8:1    0   256M  0 part 
        └─sda2        8:2    0   2.8G  0 part 
        mmcblk0     179:0    0  59.5G  0 disk 
        ├─mmcblk0p1 179:1    0   256M  0 part /boot
        └─mmcblk0p2 179:2    0  59.2G  0 part /


5. Adjust the below commands according to the lsblk output (your sda1 and sda2 partition names may be different)

        sudo mkdir /mnt/boot
        sudo mkdir /mnt/writable
        sudo mount /dev/sda1 /mnt/boot
        sudo mount /dev/sda2 /mnt/writable


6. lsblk once again to confirm /mnt/boot and /mnt/writable refer to the correct sda partitions
        
        NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        sda           8:0    0 119.2G  0 disk 
        ├─sda1        8:1    0   256M  0 part /mnt/boot
        └─sda2        8:2    0   2.8G  0 part /mnt/writable
        mmcblk0     179:0    0  59.5G  0 disk 
        ├─mmcblk0p1 179:1    0   256M  0 part /boot
        └─mmcblk0p2 179:2    0  59.2G  0 part /


7. Now run this script:

        wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/create-usb-bootable-ubuntu.sh -O create-usb-bootable-ubuntu.sh && chmod +x create-usb-bootable-ubuntu.sh && sudo ./create-usb-bootable-ubuntu.sh


8. Shutdown or Power off the RASPI and remove the MMC card.  


9. Optional Step - Create a golden master image of th converted USB SSD Image

   a. Connect the usd SSD to wondows and backup the drive with Win32Disk Imager

   b. Copy this backup image to a linux OS. (This backup will be a file the same size as the SSD - use small SSDs!)
  
   c. From linux, download and run the shrink-ubuntu.sh script to compress all the unused space in the image.
            
         wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/shrink-ubuntu.sh
         sudo ./shrink-ubuntu.sh IMAGENAME

10. Ensuring that the USB SSD is still connnected to a USB2 port, power up the Raspi. Ubuntu should boot up.


11. Run lsusb and note the command output 

         Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
         Bus 001 Device 002: ID ** 2109:3431 ** your ssd adapter, usb Inc
         Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

13.   Note the output highlighted between **   ** above. Your USB device has an numeric ID formtatted as nnnn:nnnn. 
      Change the nnnn:nnnn section of the below command to reflect YOUR 8 digit USB device ID. 
      
            sudo sed -i '1s/^/usb-storage.quirks=nnnn:nnnn:u /'  /boot/firmware/cmdline.txt
            
14. Shutdown the pi: 

          shutdown -h now

        
15. Connect ths SSD to your USB3 port and power up the Raspberry Pi once more. Ubuntu will now boot with full USB 3.0 speed.
