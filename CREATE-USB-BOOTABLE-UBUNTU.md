   ## Create a USB bootable Ubuntu Raspberry Pi Image: ##
  
  
    
1. Image your SSD with a Ubuntu image from RaspberryPi.com. Use the SMALLEST SSD you have available. (**IMAGE MUST HAVE NEVER BEEN PREVIOUSY BOOTED**) 

   https://downloads.raspberrypi.org/imager/imager_latest.exe

2. Boot your Raspberry Pi into Raspian OS from an MMC card similarly prepared as in step 1 above  

3. IMPORTANT: PLUG THE SSD INTO A **USB2.0** PORT ON THE RASPI. 

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


6. lsblk once again to confirm /mnt/boot and /mnt/writable are mounted to the correct sda partitions
        
        NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        sda           8:0    0 119.2G  0 disk 
        ├─sda1        8:1    0   256M  0 part /mnt/boot
        └─sda2        8:2    0   2.8G  0 part /mnt/writable
        mmcblk0     179:0    0  59.5G  0 disk 
        ├─mmcblk0p1 179:1    0   256M  0 part /boot
        └─mmcblk0p2 179:2    0  59.2G  0 part /


7. Now run this script:

        wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/create-usb-bootable-ubuntu.sh -O create-usb-bootable-ubuntu.sh && chmod +x create-usb-bootable-ubuntu.sh && sudo ./create-usb-bootable-ubuntu.sh


8. Shutdown or power off the RASPI and remove the MMC card.  DO NOT REBOOT.


9. OPTIONAL STEP - BEFORE BOOTING FOR THE FIRST TIME - CREATE A GOLDEN MASTER USB BOOT IMAGE

   a. Connect the USB SSD to Windows and make a block image backup with Win32Disk Imager https://sourceforge.net/projects/win32diskimager/

   b. Copy this backup image to a linux OS. 
      Note: As the backup file is a block image, it will therefore be the same size as the SSD - this is why starting with the smallest SSD avaialble is desirable.
   
     c. From linux, download and run the shrink-ubuntu.sh script to compress all the unused space in the image. 
        You will initially need double the SSD disk size available storage to compelte this step. 
        Once blank sectors are shrunk, the image will revert to the data size only
            
         wget https://raw.githubusercontent.com/itiligent/Raspi-Things/main/shrink-ubuntu.sh -O shrink-ubuntu.sh && chmod +x shrink-ubuntu.sh
         sudo ./shrink-ubuntu.sh IMAGENAME

10. Reconnect the USB SSD to a USB2 port and power up the Raspi. Ubuntu should now boot up.


11. Run lsusb and note the command output 

         Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
         Bus 001 Device 002: ID ** 2109:3431 ** your ssd adapter, usb Inc
         Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

12.  Note the lausb output highlighted between **  ** above. Your USB device has an numeric ID formtatted as nnnn:nnnn. 
      Customsie the nnnn:nnnn section of the below command to reflect YOUR 8 digit USB device ID. 
      Paste that customised command into the SSH terminal
      
            sudo sed -i '1s/^/usb-storage.quirks=nnnn:nnnn:u /'  /boot/firmware/cmdline.txt
            
13. Shutdown the pi: 

          shutdown -h now

        
14. Connect ths SSD to your USB3 port and power up the Raspberry Pi once more. Ubuntu will now boot with full USB 3.0 speed.
