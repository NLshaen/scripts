#!/bin/bash

echo "Adding ntfs support to image..."
sed -i "/%packages/antfs-3g" ../ks.cfg
echo "Done"
