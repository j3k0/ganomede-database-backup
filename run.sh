#!/bin/bash

set -e
cd "`dirname $0`"

if [[ ! -z ${INITIAL_DELAY_IN_SECONDS} ]]; then
	sleep $INITIAL_DELAY_IN_SECONDS
fi

while true; do
	./backup.sh
	sleep $INTERVAL_IN_SECONDS
done
