#!/bin/bash
# Read variable user, password, port dan host
user_destination=newuser
dir=/home/backup
date=$(date +%d-%m-%Y)
. credentials.cnf

# Make directory to save data
makedir(){
  if [ ! -d "$dir" ];
     then mkdir -p $dir;
  fi
}

# Email for notification
sendmail (){
msg_email="From: Gerda <gerda@gerda.my.id>
To: gerdaiswari89@gmail.com
Subject: Backup Notification

${status}"
curl --ssl-reqd \
--url 'smtps://smtp.gmail.com:465' \
--user "$sender:$password" \
--mail-from "$from" \
--mail-rcpt "$rcpt" \
--upload-file <(echo "$msg_email")
}

# Status Mail
success(){
status="Backup success"
sendmail
}

error(){
status="Backup failed"
sendmail
}

while true; do
    read -p "Do you want to export all database? (y/n) " yn
    case $yn in
        [Yy]* ) 
        mysqldump -u "$user_destination" -p --all-databases > $dir/$date.sql
        if [[ $? -eq 0 ]]; then
           echo "Export SQL successfully complete!"
           success;
        else
           echo "Export SQL failed!"
           status="Backup Error"
           error;
        fi
        exit;;
        [Nn]* )
				# Export Database
        read -p "Enter database name that you want to copy = " db
        makedir;
        echo "Data will be backup in /home/backup directory"
        mysqldump -u "$user_destination" -p $db > $dir/$date.sql
        if [[ $? -eq 0 ]]; then
           echo "Export SQL successfully complete!"
           success;
        else
           echo "Export SQL failed, please enter correct database name!"
           status="Backup Error"
           error;
        fi
        exit;;
        * ) echo "Please answer yes or no";;
    esac
done
