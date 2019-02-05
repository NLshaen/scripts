#!/bin/bash

[[ "${1}" == "" || "${2}" == "" || "${3}" != "" ]] && echo "Please provide two arguments : first one is the iso to burn and second one is the target device (i.e. /dev/sdb)" && exit 1

echo "Creating bootable USB drive on $2 from image $1..."
umount $2
dd bs=4M if=$1 of=$2
sync
umount $2
echo "Done, you can now remove the USB drive"
