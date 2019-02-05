#!/bin/bash

[[ "${1}" == "" || "${2}" == "" || "${3}" != "" ]] && echo "Please provide two arguments : first one is the iso to uncompress and second one is the target directory" && exit 1

echo "Extracting iso file $1 to $2..."
mkdir /mnt/stdos
mount -o loop $1 /mnt/stdos
cp -R /mnt/stdos $2
umount /mnt/stdos
rm -rf /mnt/stdos
echo "Done"
