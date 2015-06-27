#!/bin/bash

set -e
cd "`dirname $0`"

# Backup path, matches Dockerfile's VOLUME
BACKUP_PATH=/tmp/backup/$BACKUP_CONTAINER/$BACKUP_NAME
mkdir -p $BACKUP_NAME

#
# Collect backups in /backup
#

REDIS_VOLUMES=`docker ps -a | grep -e " redis-.*-vol.*$" | awk '{ print $1 }'`
MARIADB_CONTAINERS=`docker ps | grep -e " mariadb-.*$" | awk '{ print $1 }'`

for container in $REDIS_VOLUMES; do
	NAME=`docker inspect $container | grep '"Hostname"' | cut -d\" -f4`
	echo "Backing up $NAME..."
	mkdir -p $BACKUP_PATH/$NAME/data
	docker run --rm -v $BACKUP_PATH/$NAME/data:/backup --volumes-from $container jeko/redis sh -c "cp /data/* /backup/"
done

for container in $MARIADB_CONTAINERS; do
	NAME=`docker inspect $container | grep '"Hostname"' | cut -d\" -f4`
	MARIADB_PASS=`docker inspect $container | grep MARIADB_PASS | cut -d\" -f2 | cut -d= -f2`
	echo "Backing up $NAME..."
	mkdir -p $BACKUP_PATH/$NAME
	docker run --rm -v $BACKUP_PATH/$NAME:/backup --link $container:db tutum/mariadb:latest sh -c "mysqldump -h db -u admin -p$MARIADB_PASS --all-databases > /backup/all.sql"
done

#
# Send to Swift
#

echo "Uploading..."
docker run --rm \
	-e OS_USERNAME=$OS_USERNAME \
	-e OS_PASSWORD=$OS_PASSWORD \
	-e OS_AUTH_URL=$OS_AUTH_URL \
	-e OS_TENANT_NAME=$OS_TENANT_NAME \
	-e OS_TENANT_ID=$OS_TENANT_ID \
	-e OS_TENANT_NAME=$OS_TENANT_NAME \
	-e OS_REGION_NAME=$OS_REGION_NAME \
	-v $BACKUP_PATH:/$BACKUP_NAME \
	krystism/openstackclient:juno \
	swift upload --changed $BACKUP_CONTAINER /$BACKUP_NAME

#
# Cleanup
#

rm -fr $BACKUP_PATH
