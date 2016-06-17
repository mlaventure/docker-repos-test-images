#!/bin/bash

# pipe chain exit with the first non zero exit code
set -o pipefail
set -x

get_distrib_name() {
	[ -n "$DIST_NAME" ] && return 0

	if [ -f /etc/lsb-release ]
	then
		source /etc/lsb-release
		DIST_NAME="${DISTRIB_ID,,}-${DISTRIB_CODENAME}"
	elif [ -f /etc/os-release ]
	then
		source /etc/os-release
		case $ID in
			debian)
				if [ -z "${VERSION_ID}" ]
				then
					DIST_NAME="${ID}-stretch"
				else
					DIST_NAME="${ID}-$(echo ${VERSION} | sed 's/.*(\(.*\))/\1/')"
				fi
				;;
			*)
				DIST_NAME="${ID}-${VERSION_ID}"
				;;
		esac
	else
		echo "Cannot determine os version!"
		exit 1
	fi

	# Remove minor version
	if [[ $DIST_NAME =~ (\.[0-9]+$) ]]
	then
		DIST_NAME=${DIST_NAME/%${BASH_REMATCH[1]}/}
	fi
}

# graphite exporter address
GRAPHITE_EXPORTER_SERVER=${GRAPHITE_EXPORTER_SERVER:-"graphite_exporter"}

# where to install from? Install the last stable release by default
DOCKER_INSTALL_DOMAIN=${DOCKER_INSTALL_DOMAIN:-get}

# how long to wait between each retry? 1h by default
DOCKER_INSTALL_TEST_INTERVAL=${DOCKER_INSTALL_TEST_INTERVAL:-1h}

DIST_NAME=${DISTRIB_NAME:-""}

get_distrib_name

GRAPHITE_PATH="test.install.from.${DOCKER_INSTALL_DOMAIN}.docker.com.on.${DIST_NAME}"

curl -sSL https://${DOCKER_INSTALL_DOMAIN}.docker.com > install.sh

if [ -n "$DOCKER_APT_URL" ]
then
	sed -i "s,^apt_url=".*",apt_url=\"$DOCKER_APT_URL\"," install.sh
fi

if [ -n "$DOCKER_YUM_URL" ]
then
	sed -i "s,^yum_url=".*",yum_url=\"$DOCKER_YUM_URL\"," install.sh
fi

sh install.sh

# check for -q support
NC_OPT=""
if [ "$(nc -h 2>&1 | grep -- '-q')" != "" ]
then
	NC_OPTS="-q0"
fi

ec=$?
if [ $ec = 0 ]; then
	echo "${GRAPHITE_PATH} 1 $(date +%s)" | nc ${NC_OPTS} ${GRAPHITE_EXPORTER_SERVER} 9109
else
	echo "${GRAPHITE_PATH} 0 $(date +%s)" | nc ${NC_OPTS} ${GRAPHITE_EXPORTER_SERVER} 9109
fi

sleep ${DOCKER_INSTALL_TEST_INTERVAL}

exit $ec
