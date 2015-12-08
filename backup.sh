#!/bin/bash

set -e
cd "`dirname $0`"

# Backup path, matches Dockerfile's VOLUME
BACKUP_PATH=/tmp/backup/$BACKUP_CONTAINER/$BACKUP_NAME
mkdir -p $BACKUP_NAME

#
# Collect backups in /backup
#

REDIS_VOLUMES=`docker ps -a | grep -e "redis_[a-zA-Z]*Volume" | awk '{ print $1 }'`

if [[ ! -z $NO_REDIS ]]; then
    REDIS_VOLUMES=
fi

for container in $REDIS_VOLUMES; do
	NAME=`docker inspect $container | grep '"Name"' | grep redis | cut -d\" -f4 | cut -d_ -f2`
	echo "Backing up $NAME..."
	mkdir -p $BACKUP_PATH/$NAME/data
	docker run --rm -v $BACKUP_PATH/$NAME/data:/backup --volumes-from $container jeko/redis sh -c "cp /data/* /backup/"
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
