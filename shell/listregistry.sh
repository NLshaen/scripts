#!/bin/bash

while read image; do
  echo "$image :"
  while read tag; do
    tagdigest=$(curl -s -k -v -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET "http://elrepo.sccopen.net:5000/v2/$image/manifests/${tag%$'\r'}" 2>/dev/null | grep "\"digest\":" | head -n 1 | sed -e "s/.*sha256:\(.*\)\"/\1/g")
    echo -e "\t$tag ($tagdigest)"
  done< <(curl -s -X GET http://elrepo.sccopen.net:5000/v2/$image/tags/list | sed -e "s/.*\[//" | sed -e "s/\].*//g" | sed -e "s/\"//g" | tr "," "\n")
done< <(curl -s -X GET http://elrepo.sccopen.net:5000/v2/_catalog | sed -e "s/.*\[//" | sed -e "s/\].*//g" | sed -e "s/\"//g" | tr "," "\n")
