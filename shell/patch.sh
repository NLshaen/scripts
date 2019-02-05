#!/bin/bash

set -e

rm -rf /tmp/uniso
./uniso.sh ../base/BSR_STDOS_Centos_7.1_2.5.0_x86_64.iso /tmp/uniso
mv ../ks.cfg ../ks.cfg.$(date +%s)
cp /tmp/uniso/ks.cfg ../
# text installation installs a headless version (need to startx manually on the machine to start X server)
#./textinstall.sh
#./addhpdrivers.sh /tmp/uniso
#./removerepo.sh /tmp/uniso
#./ejectonreboot.sh
#./raid.sh
# ntfs-3g is only available on epel repo
#./ntfs-3g.sh
./disk.sh

#echo "If you want to do any manual modification on configuration file ../ks.cfg, do it now then press any key. Note that you can also modify other files directly from /tmp/uniso"
#read

./updateimage.sh /tmp/uniso
#./updateinitrd.sh /tmp/uniso/isolinux/initrd.img
rm -rf ../output
mkdir ../output
./geniso.sh /tmp/uniso ../output/DSR3.1.iso
