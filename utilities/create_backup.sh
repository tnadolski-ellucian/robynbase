#!/bin/bash

# defaults
SOURCE_DB=robyn_dev
BACKUP_DB=robyn_dev_backup
USER=root

# create the backup daatabase
echo "Creating backup db $BACKUP_DB"

mysql -u $USER -e "drop database $BACKUP_DB;"
mysql -u $USER -e "create database $BACKUP_DB;"

# dump the source db
echo "Dumping source db $SOURCE_DB"
mysqldump --column-statistics=0 -u root $SOURCE_DB > $SOURCE_DB.sql

# hydrate the backup db
echo "Hydrating backup db $BACKUP_DB"
mysql -u root $BACKUP_DB < $SOURCE_DB.sql