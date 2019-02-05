#!/bin/bash

[[ "${1}" == "" || "${2}" != "" ]] && echo "Please provide one argument : the path of the extracted iso to patch" && exit 1

echo "Removing packages from image $1..."
rm -rf $1/Packages
rm -rf $1/repodata
echo "Done"

echo "Patching ks.cfg to point on network packages repository..."
sed -i "s|^cdrom$|url --url http://172.30.172.156:8090/repos/centos/7.1.1503/os/x86_64/|" ../ks.cfg
sed -i "s|^network.*|network --activate --onboot=on --bootproto=static --ip=172.30.173.41 --netmask=255.255.254.0 --gateway=172.30.172.254 --nameserver=172.30.172.150|" ../ks.cfg
echo "Done"
