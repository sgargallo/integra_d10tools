#!/bin/bash
mount -t cifs -o user=marketing,dom=.,password=Efor.2014! //192.168.12.60/Sites/Starkiller /mnt/nas_mkt_backup_smb 

TIMESTAMP=$(date +"%A")

BACKUP_DIR_MYSQL="/mnt/nas_mkt_backup_smb/$TIMESTAMP/mysql"
BACKUP_DIR_WWW="/mnt/nas_mkt_backup_smb/$TIMESTAMP/www"

BACKUP_DIR_MYSQL_CONTENTS="/mnt/nas_mkt_backup_smb/$TIMESTAMP/mysql/*"
BACKUP_DIR_WWW_CONTENTS="/mnt/nas_mkt_backup_smb/$TIMESTAMP/www/*"

MYSQL_USER="eformedia"
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD="efor2017"
MYSQLDUMP=/usr/bin/mysqldump

mkdir -p $BACKUP_DIR_MYSQL
mkdir -p $BACKUP_DIR_WWW

rm $BACKUP_DIR_MYSQL_CONTENTS
rm $BACKUP_DIR_WWW_CONTENTS

cd /var/www/html/

for dir in */
do
	base=$(basename "$dir")
	tar -czf "${base}.tar.gz" "$dir"
	mv "${base}.tar.gz" "$BACKUP_DIR_WWW"
done

databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|phpmyadmin)"`

for db in $databases; do
	$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR_MYSQL/$db.gz"
done

umount //192.168.12.60/Sites/Starkiller
