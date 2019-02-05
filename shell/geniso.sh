#!/bin/bash

[[ "${1}" == "" || "${2}" == "" || "${3}" != "" ]] && echo "Please provide two arguments : first one is the directory to isofy and second one is the target iso file" && exit 1

echo "Generating $2 ISO file from image $1..."
genisoimage -r -T -J -V "BSRSTDOS" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $2 $1 && isohybrid $2
echo "Done"
