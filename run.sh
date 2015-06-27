#!/bin/bash

set -e
cd "`dirname $0`"

while true; do
	./backup.sh
	sleep $INTERVAL_IN_SECONDS
done
