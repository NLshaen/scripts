#!/bin/bash

[[ "${1}" == "" || "${2}" != "" ]] && echo "Please provide one argument : the path of the extracted image to patch" && exit 1

echo "Adding HP drivers iso to image..."
cp ../base/hp_drivercd_rhel7_sp74249.iso $1
echo "Done"

echo "Adding installation directives to ks file..."
sed -i "/systemctl restart snmpd/{
a\
\ \n# HP specific drivers\nmkdir \/mnt\/HPDrivers\nmount -o loop \/media\/cdrom\/hp_drivercd_rhel7_sp74249.iso \/mnt\/HPDrivers\n\/mnt\/HPDrivers\/HP\/scripts\/install.sh\numount \/mnt\/HPDrivers\nrm -rf \/mnt\/HPDrivers\n
}" ../ks.cfg
echo "Done"
