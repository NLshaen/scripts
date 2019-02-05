#!/bin/bash

[[ "${1}" == "" || "${2}" != "" ]] && echo "Please provide one argument : the initrd.img file to patch" && exit 1

echo "Updating initrd.img file with ks.cfg file..."
mkdir /tmp/imgmod && cd /tmp/imgmod && xz -d < $1 | cpio --extract --make-directories --no-absolute-filenames
rm -rf $1
cd -
cp ../ks.cfg /tmp/imgmod/
cd /tmp/imgmod/
find . | cpio -H newc --create | xz --format=lzma --compress --stdout > $1
cd -
rm -rf /tmp/imgmod
echo "Done"
