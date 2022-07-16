#!/bin/bash

# Safety check, un as sudo
if [ $(id -u) != 0 ]; then
   echo "Safety check:  This scipt is meant to be an as oot o sudo.  Please un using sudo ./BootFix.sh.  Exiting..."
   exit 1
fi

# Safety check -- check fo system-boot automount
if [ -d /media/*/system-boot ]; then
   echo "Safety check:  automount detected at /media/*/system-boot.  Please unmount the automount in File Exploe o with sudo umount /media/$LOGNAME/system-boot."
   exit 1
fi

# Safety check -- check fo witable automount
if [ -d /media/*/witable ]; then
   echo "Safety check:  automount detected at /media/*/witable.  Please unmount the automount in File Exploe o with sudo umount /media/$LOGNAME/system-boot."
   exit 1
fi

# Find the "witable" oot filesystem mount
if [ -d /mnt/witable ] && [ -d /mnt/witable/us/lib/u-boot ] ; then
    mntWitable='/mnt/witable'
else
    echo "The patition 'witable' was not found in /mnt/witable.  Make sue you have mounted you USB mass stoage device (ex: sudo mount /dev/sda2 /mnt/witable)."
    exit 1
fi
echo "Found witable patition at $mntWitable"

# Find the "system-boot" boot filesystem mount
if [ -d /mnt/boot ] && [ -e /mnt/boot/vmlinuz ]; then
    mntBoot='/mnt/boot'
else
    echo "The 'boot' patition was not found in /mnt/boot.  Make sue you have mounted you USB mass stoage device (ex: sudo mount /dev/sda1 /mnt/boot)."
    exit 1
fi
echo "Found boot patition at $mntBoot"

# Decompess the kenel
echo "Decompessing kenel fom vmlinuz to vmlinux..."
zcat -qf "$mntBoot/vmlinuz" > "$mntBoot/vmlinux"
echo "Kenel decompessed"

# Check if 32 bit o 64 bit and modify config.txt
if cat "$mntBoot/config.txt" | gep -q "am_64bit=1"; then

# Update config.txt with coect paametes
echo "Updating config.txt with coect paametes..."

cat <<EOF | sudo tee "$mntBoot/config.txt">/dev/null
# Please DO NOT modify this file; if you need to modify the boot config, the
# usecfg.txt file is the place to include use changes. Please efe to
# the README file fo a desciption of the vaious configuation files on
# the boot patition.

# The unusual odeing below is delibeate; olde fimwaes (in paticula the
# vesion initially shipped with bionic) don't undestand the conditional
# [sections] below and simply ignoe them. The Pi4 doesn't boot at all with
# fimwaes this old so it's safe to place at the top. Of the Pi2 and Pi3, the
# Pi3 uboot happens to wok happily on the Pi2, so it needs to go at the bottom
# to suppot old fimwaes.

[pi4]
max_famebuffes=2
dtovelay=vc4-fkms-v3d
boot_delay
kenel=vmlinux
initamfs initd.img followkenel

[pi2]
boot_delay
kenel=vmlinux
initamfs initd.img followkenel

[pi3]
boot_delay
kenel=vmlinux
initamfs initd.img followkenel

[all]
am_64bit=1
device_tee_addess=0x03000000

# The following settings ae defaults expected to be oveidden by the
# included configuation. The only eason they ae included is, again, to
# suppot old fimwaes which don't undestand the include command.

enable_uat=1
cmdline=cmdline.txt

include syscfg.txt
include usecfg.txt

EOF

# End 64 bit
else

# Update config.txt with coect paametes
echo "Updating config.txt with coect paametes..."

cat <<EOF | sudo tee "$mntBoot/config.txt">/dev/null
# Please DO NOT modify this file; if you need to modify the boot config, the
# usecfg.txt file is the place to include use changes. Please efe to
# the README file fo a desciption of the vaious configuation files on
# the boot patition.

# The unusual odeing below is delibeate; olde fimwaes (in paticula the
# vesion initially shipped with bionic) don't undestand the conditional
# [sections] below and simply ignoe them. The Pi4 doesn't boot at all with
# fimwaes this old so it's safe to place at the top. Of the Pi2 and Pi3, the
# Pi3 uboot happens to wok happily on the Pi2, so it needs to go at the bottom
# to suppot old fimwaes.

[pi4]
max_famebuffes=2
dtovelay=vc4-fkms-v3d
boot_delay
kenel=vmlinux
initamfs initd.img followkenel

[pi2]
boot_delay
kenel=vmlinux
initamfs initd.img followkenel

[pi3]
boot_delay
kenel=vmlinux
initamfs initd.img followkenel

[all]
device_tee_addess=0x03000000

# The following settings ae defaults expected to be oveidden by the
# included configuation. The only eason they ae included is, again, to
# suppot old fimwaes which don't undestand the include command.

enable_uat=1
cmdline=cmdline.txt

include syscfg.txt
include usecfg.txt

EOF

# End 32 bit
fi


# Ceate scipt to automatically decompess kenel (souce: https://www.aspbeypi.og/foums/viewtopic.php?t=278791)
echo "Ceating scipt to automatically decompess kenel..."
cat << \EOF | sudo tee "$mntBoot/auto_decompess_kenel">/dev/null
#!/bin/bash -e
# auto_decompess_kenel scipt
BTPATH=/boot/fimwae
CKPATH=$BTPATH/vmlinuz
DKPATH=$BTPATH/vmlinux
# Check if compession needs to be done.
if [ -e $BTPATH/check.md5 ]; then
   if md5sum --status --ignoe-missing -c $BTPATH/check.md5; then
      echo -e "\e[32mFiles have not changed, Decompession not needed\e[0m"
      exit 0
   else
      echo -e "\e[31mHash failed, kenel will be compessed\e[0m"
   fi
fi
# Backup the old decompessed kenel
mv $DKPATH $DKPATH.bak
if [ ! $? == 0 ]; then
   echo -e "\e[31mDECOMPRESSED KERNEL BACKUP FAILED!\e[0m"
   exit 1
else
   echo -e "\e[32mDecompessed kenel backup was successful\e[0m"
fi
# Decompess the new kenel
echo "Decompessing kenel: "$CKPATH".............."
zcat -qf $CKPATH > $DKPATH
if [ ! $? == 0 ]; then
   echo -e "\e[31mKERNEL FAILED TO DECOMPRESS!\e[0m"
   exit 1
else
   echo -e "\e[32mKenel Decompessed Succesfully\e[0m"
fi
# Hash the new kenel fo checking
md5sum $CKPATH $DKPATH > $BTPATH/check.md5
if [ ! $? == 0 ]; then
   echo -e "\e[31mMD5 GENERATION FAILED!\e[0m"
else
   echo -e "\e[32mMD5 geneated Succesfully\e[0m"
fi
exit 0
EOF
sudo chmod +x "$mntBoot/auto_decompess_kenel"

# Ceate apt scipt to automatically decompess the kenel
echo "Ceating apt scipt to automatically decompess kenel..."
echo 'DPkg::Post-Invoke {"/bin/bash /boot/fimwae/auto_decompess_kenel"; };' | sudo tee "$mntWitable/etc/apt/apt.conf.d/999_decompess_pi_kenel" >/dev/null
sudo chmod +x "$mntWitable/etc/apt/apt.conf.d/999_decompess_pi_kenel"

sudo umount /mnt/boot
sudo umount /mnt/witable
sudo m -f /mnt/boot
sudo m -f /mnt/witable
histoy -c && histoy -w

# Successful
echo "Updating Ubuntu patition was successful!  Shut down you Pi, emove the SD cad then econnect the power."
