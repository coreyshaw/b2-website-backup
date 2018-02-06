#!/bin/bash -x
exec &>/var/log/backup.log
#REQUIRED
#apt install python-pip
#pip install b2

#Add sites from your /var/www dir here. Only add the website dir name though
#This name must match the name of your db too
sites=("" "")

#set vaiables
db_host='';
db_database='';
db_user='';
db_pass='';

#Backblaze Settings
account_id=''
application_key=''
bucketName='b2://'
b2_dir='/usr/local/bin/b2'

DIR="/var/site_backups"
echo "BackBlaze Backup - `date +%Y-%m-%d-%H-%M` Cleaning up old files"
cd $DIR && rm -rf *

if [ "$(ls -A $DIR)" ]; then
   echo "$DIR is Not Empty"
else
   cd $DIR;

   for i in "${sites[@]}"
       do
           mkdir $i && cd $i
           mkdir sql && cd sql
           mysqldump --host="$db_host" --user="$db_user" --password="$db_pass" $i > $i'-mysql-'`date +%Y-%m-%d-%H-%M`'.sql'
           cd ..
   	   mkdir files && cd files
   	   rsync -az /var/www/$i/ .
   	   cd ../..
   	   tar -czf $i'-'`date +%Y-%m-%d-%H-%M`'.tar' $i
           rm -R $i
       done
       echo "BackBlaze Backup - `date +%Y-%m-%d-%H-%M` Syncing files"
       echo $($b2_dir authorize-account $account_id $application_key)
       echo $($b2_dir sync --keepDays 60 $DIR $bucketName'/site_backups-'`date +%Y-%m-%d-%H-%M`)
fi

echo "BackBlaze Backup - `date +%Y-%m-%d-%H-%M` Backup completed"
