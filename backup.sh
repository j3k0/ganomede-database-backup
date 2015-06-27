#!/bin/bash

set -e
cd "`dirname $0`"

BACKUP_PATH=/backup

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
	docker run --rm -it --link $container:db tutum/mariadb:latest mysqldump -h db -u admin -p$MARIADB_PASS --all-databases > $BACKUP_PATH/$NAME/all.sql
done

#
# Send to Swift
#

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
	swift upload $BACKUP_CONTAINER /$BACKUP_NAME
