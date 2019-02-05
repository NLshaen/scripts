#!/bin/bash

[[ "${1}" == "" || "${2}" != "" ]] && echo "Please provide one argument : the path of the extracted iso to patch" && exit 1

echo "Copying configuration file ks.cfg to $1 image..."
cp ../ks.cfg $1/ks.cfg
cp ../ks.cfg $1/isolinux/ks.cfg
echo "Done"
