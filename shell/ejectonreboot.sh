#!/bin/bash

echo "Patching ks.cfg file to eject CDROM on reboot..."
sed -i "s|reboot|reboot --eject|" ../ks.cfg
echo "Done"
