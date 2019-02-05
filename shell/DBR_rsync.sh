#!/bin/bash

#DBR_rsync script

export PATH=$PATH:/usr/bin
export PATH=$PATH:$HOME/bin

#VARIABLES à changer en fonction des repertoires a sauvegarder

RSYNC_DIR1="/root/scripts/"
RSYNC_DIR2="/home/datamgr/"

RSYNC_DEST="/mnt/secbudbr/"

#Nettoyage des logs de plus de 7 jours

find /mnt/secbudbr/logs/ -name "*.log" -mtime +7 -exec rm {} \;

sleep 2

#Sauvegarde par rsync sur share distant

rsync -azvL --progress --out-format="%t %f %b" --log-file=/var/log/rsync.log $RSYNC_DIR1 $RSYNC_DIR1 $RSYNC_DEST > /mnt/secbudbr/logs/"$HOSTNAME"_rsync_`date +%Y%m%d_%H\H\%M`.log 2> /mnt/secbudbr/logs/"$HOSTNAME"_error_rsync_`date +%Y%m%d_%H\H\%M`.log
