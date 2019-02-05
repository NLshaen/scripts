#!/bin/bash
#
# Backup the COMPASS data (SAG + ONLINE data)
#
## Usage : compass_data_sync_dbr.sh <backup_folder>
#
# 1.0.x: First release
# 1.1.x: tar archive are to big. Based file backup on Rsync

VERSION="1.1.0"

DATE=`date +%Y%m%d-%H%M%S`
BACKUP_NAME=compass_data_backup
BACKUP_SAG_DATABASE_NAME=sag_database.pg_dump
BACKUP_SAG_DATA_NAME=file_backup
SAG_ROOT=/SAG
SAG_DATA=$SAG_ROOT/OPERATIONNEL/EN_LIGNE

LOG_FILE=/opt/facilities/COMPASS/logs/compass_data_sync_dbr-$DATE.log

# Functions
#-----------------------------------------------------------------------------

displaymessage() {
  echo "$*"
}

displaytitle() {
  displaymessage "------------------------------------------------------------------------------"
  displaymessage "$*"
  displaymessage "------------------------------------------------------------------------------"

}
displayerror() {
  displaymessage "$*" >&2
}

# First parameter: ERROR CODE
# Second parameter: MESSAGE
displayerrorandexit() {
  local exitcode=$1
  shift
  displayerror "$*"
  exit $exitcode
}

# First parameter: MESSAGE
# Others parameters: COMMAND (! not |)
displayandexec() {
  local message=$1
  echo -n "[En cours] $message"
  shift
  echo ">>> $*" >> $LOG_FILE 2>&1
  sh -c "$*" >> $LOG_FILE 2>&1
  local ret=$?
  if [ $ret -ne 0 ]; then
    echo -e "\r\e[0;31m   [ERROR]\e[0m $message"
  else
    echo -e "\r\e[0;32m      [OK]\e[0m $message"
  fi
  return $ret
}


# Main
#-----------------------------------------------------------------------------

#########################################   ROOT NEED   ######################################
if [ "$(id -u)" != "0" ];
then
        displayerrorandexit 1 "Error: Script should be ran as root..." 1>&2
fi

#########################################   SET BACKUP DIR   ######################################
if [[ -d $1  ]]
then
  if [[ $1 == '.' ]]
  then
    BACKUP_WORKING_DIR=$PWD
  else
    BACKUP_WORKING_DIR=$1
  fi
else
  displayerrorandexit 1 "Usage : compass-backup.sh <backup_folder>"
fi

if [[ -d $2  ]]
then
  if [[ $2 == '.' ]]
  then
    ARCHIVES_WORKING_DIR=$PWD
  else
    ARCHIVES_WORKING_DIR=$1
  fi
else
  displayerrorandexit 1 "Usage : compass-backup.sh <backup_folder>"
fi

#########################################   BACKUP SAG   ######################################
displaytitle "Backup COMPASS data to $BACKUP_WORKING_DIR/$BACKUP_NAME"
displaymessage "Backup log file: $LOG_FILE"

displayandexec "Create backup folder" mkdir -p $BACKUP_WORKING_DIR/$BACKUP_NAME  && mkdir -p $SAG_ROOT/tmp && chmod 777  $SAG_ROOT/tmp

displayandexec "Create file backup folder" mkdir -p $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATA_NAME && chmod 777 $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATA_NAME

displayandexec "Stop SAG Tomcat server" /usr/sbin/service tomcat stop && sleep 5

displayandexec "Ensure postgresql service is up" systemctl start postgresql && sleep 2
su postgres -c "pg_dump -F c -v -f $SAG_ROOT/tmp/$BACKUP_SAG_DATABASE_NAME sagopdb" >> $LOG_FILE 2>&1
displayandexec "Dump SAG PostGre database" "(exit $?)"

displayandexec "Backup SAG PostGre database" mv $SAG_ROOT/tmp/$BACKUP_SAG_DATABASE_NAME $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATABASE_NAME

# Note: do not forgot the / caracter after the source folder
displayandexec "Backup SAG data by Sync" rsync -avz --del --exclude ARCHIVES $SAG_DATA/ $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATA_NAME >> $LOG_FILE 2>&1
#mkdir -p $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATA_NAME/ARCHIVES
rsync -avz --del $SAG_DATA/ARCHIVES/ $ARCHIVES_WORKING_DIR &
ARCHIVES_RSYNC_PID=$!
displayandexec "Restart SAG Tomcat server" systemctl restart tomcat

displayandexec "Clean folder" rm -fR $SAG_ROOT/tmp

echo -n "Waiting for ARCHIVES synch..."
wait ${ARCHIVES_RSYNC_PID}
echo "OK"

#########################################   SUMMARY   ######################################

displaytitle "Backup successful"
displaymessage "Backup log file:          $LOG_FILE"
displaymessage "PostGre database archive: $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATABASE_NAME"
displaymessage "Data archive folder:      $BACKUP_WORKING_DIR/$BACKUP_NAME/$BACKUP_SAG_DATA_NAME"
displaymessage "How to restore this backup ?"
displaymessage "=> compass-restore.sh $BACKUP_WORKING_DIR/$BACKUP_NAME"
