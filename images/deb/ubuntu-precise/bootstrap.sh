#!/bin/bash

set -x

env | grep -v LS_COLORS > /testenv

DOCKER_INSTALL_TEST_INTERVAL=${DOCKER_INSTALL_TEST_INTERVAL:-1h}

# convert interval to crontab format
if [[ ! "${DOCKER_INSTALL_TEST_INTERVAL}" =~ ^[0-9]+[mh]$ ]]
then
	echo 'DOCKER_INSTALL_TEST_INTERVAL must be in the following format: ^[0-9]+[mh]$'
	exit 1
fi

hours='*'
mins='*'

num=${DOCKER_INSTALL_TEST_INTERVAL:0:-1}
unit=${DOCKER_INSTALL_TEST_INTERVAL: -1}
if [ "$unit" = "m" ]
then
	mins=$(( $num % 60 ))
	hours=$(( $num / 60 ))
else
	hours=$num
fi

if [[ $hours > 23 ]]
then
	echo "Hours interval cannot exceed 23"
	exit 1
fi

[ "$hours" = '0' ] && hours='*'

if [ "$mins" != '*' ] && [ "$mins" != "0" ]
then
	mins="*/$mins"
fi

if [ "$hours" != '*' ]
then
	hours="*/$hours"
fi

echo -n "" > /var/log/docker-install.log

echo "$mins $hours * * * root /usr/local/bin/docker-install.sh 2>&1 >> /var/log/docker-install.log" > /etc/cron.d/docker-install
