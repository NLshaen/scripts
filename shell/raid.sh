#!/bin/bash

echo "Patching ks.cfg file to use raid instead of simple disks..."

if [[ "" != $(grep "^# Ignore USB key" ../ks.cfg) ]]; then
    sed "/^# Ignore USB key/,/\EOF/{d}" ../ks.cfg > /tmp/ks.cfg.tmp
elif [[ "" != $(grep "^# System bootloader configuration" ../ks.cfg) ]]; then
    sed "/^# System bootloader configuration/,/\EOF/{d}" ../ks.cfg > /tmp/ks.cfg.tmp
else
    echo "Unable to locate disk management section start in ks.cfg" >&2 && exit 1
fi 
echo "1/3"




echo "# Ignore USB key
ignoredisk --only-use=sda,sdb

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda --driveorder=sda,sdb --append=" crashkernel=auto"

# Clear the Master Boot Record
zerombr

# Partition configuration
clearpart --all --drives=sda,sdb --initlabel
part biosboot.0 --fstype=biosboot --size=1 --ondisk=sda --asprimary
part biosboot.1 --fstype=biosboot --size=1 --ondisk=sdb --asprimary
part raid.0 --size=5000 --ondisk=sda
part raid.1 --size=5000 --ondisk=sdb
part raid.2 --size=2000 --ondisk=sda
part raid.3 --size=2000 --ondisk=sdb
part raid.4 --size=500 --ondisk=sda
part raid.5 --size=500 --ondisk=sdb
part raid.6 --size=8000 --ondisk=sda
part raid.7 --size=8000 --ondisk=sdb
part raid.8 --size=50000 --ondisk=sda
part raid.9 --size=50000 --ondisk=sdb
part raid.10 --size=8192 --ondisk=sda
part raid.11 --size=8192 --ondisk=sdb
part raid.12 --size=1000 --grow --ondisk=sda
part raid.13 --size=1000 --grow --ondisk=sdb
raid /tmp --fstype ext3 --level=RAID1 --device=md0 raid.0 raid.1
raid /var --fstype ext3 --level=RAID1 --device=md1 raid.2 raid.3
raid /var/log --fstype ext3 --level=RAID1 --device=md2 raid.4 raid.5
raid /home --fstype ext3 --level=RAID1 --device=md3 raid.6 raid.7
raid / --fstype ext3 --level=RAID1 --device=md4 raid.8 raid.9
raid swap --fstype swap --level=RAID1 --device=md5 raid.10 raid.11
raid /data --fstype ext3 --level=RAID1 --device=md6 raid.12 raid.13" >> /tmp/ks.cfg.tmp
echo "2/3"





if [[ "" != $(grep "^# Ignore USB key" ../ks.cfg) ]]; then
    sed "0,/^raid \/data/{d}" ../ks.cfg >> /tmp/ks.cfg.tmp
elif [[ "" != $(grep "^# System bootloader configuration" ../ks.cfg) ]]; then
    sed "0,/^part swap/{d}" ../ks.cfg >> /tmp/ks.cfg.tmp
else
    echo "Unable to locate disk management section end in ks.cfg" >&2 && exit 1
fi
echo "3/3"

mv /tmp/ks.cfg.tmp ../ks.cfg
echo "Done"
