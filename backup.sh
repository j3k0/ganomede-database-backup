#!/bin/bash

set -e
cd "`dirname $0`"

. inc/openstack.sh

#
# Collect backups in ./files
#

REDIS_VOLUMES=`docker ps -a | grep -e " redis-.*-vol.*$" | awk '{ print $1 }'`
MARIADB_CONTAINERS=`docker ps | grep -e " mariadb-.*$" | awk '{ print $1 }'`

for container in $REDIS_VOLUMES; do
	NAME=`docker inspect $container | grep '"Hostname"' | cut -d\" -f4`
	echo "Backing up $NAME..."
	mkdir -p files/$NAME/data
	docker run --rm -v `pwd`/files/$NAME/data:/backup --volumes-from $container jeko/redis sh -c "cp /data/* /backup/"
done

for container in $MARIADB_CONTAINERS; do
	NAME=`docker inspect $container | grep '"Hostname"' | cut -d\" -f4`
	MARIADB_PASS=`sudo docker inspect $container | grep MARIADB_PASS | cut -d\" -f2 | cut -d= -f2`
	echo "Backing up $NAME..."
	mkdir -p files/$NAME
	docker run --rm -it --link $container:db tutum/mariadb:latest mysqldump -h db -u admin -p$MARIADB_PASS --all-databases > files/$NAME/all.sql
done

#
# Send to Swift
#

swift upload golias-redis files/
