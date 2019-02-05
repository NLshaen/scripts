#!/bin/bash

echo "Patching ks.cfg file to use a big / partition..."

if [[ "" != $(grep "^# Partition configuration" ../ks.cfg) ]]; then
    sed "/^# Partition configuration/,/\EOF/{d}" ../ks.cfg > /tmp/ks.cfg.tmp
else
    echo "Unable to locate disk management section start in ks.cfg" >&2 && exit 1
fi 
echo "1/3"

echo "# Partition configuration
clearpart --all --initlabel
#autopart --type=lvm
ignoredisk --only-use=sda
part / --fstype=\"ext3\" --size=50000 --grow
part swap --fstype=\"swap\" --recommended" >> /tmp/ks.cfg.tmp
echo "2/3"

if [[ "" != $(grep "^# Partition configuration" ../ks.cfg) ]]; then
    sed "0,/^part swap/{d}" ../ks.cfg >> /tmp/ks.cfg.tmp
else
    echo "Unable to locate disk management section end in ks.cfg" >&2 && exit 1
fi
echo "3/3"

mv /tmp/ks.cfg.tmp ../ks.cfg
echo "Done"
