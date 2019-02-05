#!/bin/bash

export PATH=$PATH:$HOME/bin
export PATH=$PATH:/usr/bin

set +e
set -o xtrace

#Variables MOUNT CIFS

DBR_MOUNT="$(awk '{print $2}' /proc/mounts | grep -s "/mnt/secbudbr")"
DBR_CIFS="//cabuvtl01.aes.alcatel.fr/CCSLF"
DBR_CIFS_DIR="//cabuvtl01.aes.alcatel.fr/CCSLF/${HOSTNAME}"
DBR_MBASE="/mnt/secbudbr"
DBR_MDIR="/mnt/secbudbr/${HOSTNAME}"
DBR_MLOG="/mnt/secbudbr/logs"

#Variables FSTAB

DBR_FSTAB="$(awk '{print $2}' /etc/fstab | grep -s "/mnt/secbudbr")" >/dev/null

#Variables CRONTAB

CRONFILE="/var/spool/cron/${USER}"

#Variables SCRIPT RSYNC

DBR_SH="/$USER/scripts/DBR_rsync.sh"

DBR_RSYNC="$(echo -e '#!/bin/bash\n
#DBR_rsync script\n
export PATH=$PATH:/usr/bin
export PATH=$PATH:$HOME/bin\n
#VARIABLES à changer en fonction des repertoires a sauvegarder\n
RSYNC_DIR1="/root/scripts/"
RSYNC_DIR2="/home/datamgr/"\n
RSYNC_DEST="/mnt/secbudbr/"\n
#Nettoyage des logs de plus de 7 jours\n
find /mnt/secbudbr/logs/ -name "*.log" -mtime +7 -exec rm {} \;\n
sleep 2\n
#Sauvegarde par rsync sur share distant\n
rsync -azvL --progress --out-format="%t %f %b" --log-file=/var/log/rsync.log $RSYNC_DIR1 $RSYNC_DIR1 $RSYNC_DEST > /mnt/secbudbr/logs/"$HOSTNAME"_rsync_`date +%Y%m%d_%H\H\%M`.log 2> /mnt/secbudbr/logs/"$HOSTNAME"_error_rsync_`date +%Y%m%d_%H\H\%M`.log\n')"

#Create script file DBR_rsync.sh

if [ ! -e = "$DBR_SH" ];
  then
        echo -e "Creation du script $DBR_SH"
        mkdir -p /$USER/scripts/ && touch $DBR_SH && chmod +x $DBR_SH && echo -e "${DBR_RSYNC}" > $DBR_SH
  else
        echo -e "Le fichier $DBR_RSYNC existe deja"
fi

#Create file crontab dans /var/spool/cron/

if [ ! -e "$CRONFILE" ];
  then
        echo -e "Creation de la crontab $CRONFILE"
        touch /var/spool/cron/${USER} && echo -e "\nSHELL=/bin/bash\n\nMAILTO=\"yan.lucas@external.thalesaleniaspace.com\"\n\n30 0 * * * /${USER}/scripts/DBR_rsync.sh" | tee -a /var/spool/cron/${USER}

  else
        echo -e "La crontab pour l utilisateur ${USER} existe deja"
fi

#Check if mount DBR //cabuvtl01.aes.alcatel.fr/ccslf don t exist, create it

if [ ! -d "$DBR_MOUNT" ];
 then
       echo -e "Montage du share $DBR_CIFS";
	mkdir -p -v $DBR_MBASE && mount -t cifs -v $DBR_CIFS $DBR_MBASE -o username=username,password=password
       sleep 5
       cd $DBR_MBASE && mkdir -p -v $HOSTNAME && chmod -v 755 $DBR_MDIR && cd -;
       sleep 2
	echo -e "Demontage du share $DBR_CIFS";
       umount -v $DBR_CIFS
        sleep 5
	echo -e "Montage du share $DBR_CIFS_DIR";
        mount -t cifs -v $DBR_CIFS_DIR $DBR_MBASE -o username=username,password=password
	sleep 5
	#echo -e "Définition des droits 755 pour $DBR_MDIR";
	#echo -e "Définition des droits 755 pour $DBR_MDIR";
	#chmod -v 755 $DBR_MDIR;
  else
	echo -e "Creation du repertoire $DBR_MDIR et definition des droits 755";
        mkdir -p -v $DBR_MDIR && chmod -v 755 $DBR_MDIR;
fi

#Check in /etc/fstab if /mnt/secbudbr exist

if [ ! -d "$DBR_FSTAB" ]
  then
	echo -e "Ecriture de $DBR_CIFS_DIR dans le fichier /etc/fstab"
	echo -e "//cabuvtl01.aes.alcatel.fr/ccslf/$HOSTNAME /mnt/secbudbr cifs auto,username=username,password=password,rw 0 0" >> /etc/fstab
  else
	echo -e "Montage existe deja dans /etc/fstab"

fi

#Check if directory /logs don t exist, create it

if [ ! -d "$DBR_MLOG" ];
  then
	echo -e "Creation du repertoire $DBR_MLOG"
	mkdir -p -v $DBR_MLOG
  else
	echo -e "Le repertoire $DBR_MLOG existe deja "

fi

exit 0;

