
How to expand a newly imaged Raspi filesystem to use all available disk or memory card space.

   ##Ubuntu:
   
      clear && sudo fdisk /dev/mmcblk0 
        then enter the following EXACTLY in sequece..
        d   2   n   p   2   enter   enter   n   w   
        reboot
        sudo resize2fs /dev/mmcblk0p2

   ##Raspian: (can be set to auto expand at capture via shrink-pi.sh)
   
      sudo raspi-config
      advanced options 
      expand filesystem
      ok
      finish
      yes (to reboot)
  
