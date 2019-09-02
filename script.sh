#!/bin/bash

# Linux MySQL Database FTP Backup Script
# Version: 1.0
# Script by: Pietro Marangon
# Skype: pe46dro
# Email: pietro.marangon@gmail.com
# SFTP function by unixfox and Pe46dro

backup_path="/tmp"

create_backup() {
  umask 177

  FILE="$db_name-$d.sql.gz"
  mysqldump --user=$user --password=$password --host=$host $db_name | gzip --best > $FILE

  echo 'Backup Complete'
}

clean_backup() {
  rm -f $backup_path/$FILE
  echo 'Local Backup Removed'
}

########################
# Edit Below This Line #
########################

# Database credentials

user="USERNAME HERE"
password="PASSWORD HERE"
host="IP HERE"
db_name="DATABASE NAME HERE"

# FTP Login Data
USERNAME="USERNAME HERE"
PASSWORD="PASSWORD HERE"
SERVER="IP HERE"
PORT="SERVER PORT HERE"

#Remote directory where the backup will be placed
REMOTEDIR="./"

#Transfer type
#1=FTP
#2=SFTP
TYPE=1

##############################
# Don't Edit Below This Line #
##############################

d=$(date +%u)
cd $backup_path
create_backup

if [ $TYPE -eq 1 ]
then
ftp -n -i $SERVER <<EOF
user $USERNAME $PASSWORD
binary
cd $REMOTEDIR
mput $FILE
quit
EOF
elif [ $TYPE -eq 2 ]
then
rsync --rsh="sshpass -p $PASSWORD ssh -p $PORT -o StrictHostKeyChecking=no -l $USERNAME" $backup_path/$FILE $SERVER:$REMOTEDIR
else
echo 'Please select a valid type'
fi

echo 'Remote Backup Complete'
clean_backup
#END
