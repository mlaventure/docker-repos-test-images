#!/bin/bash

# pipe chain exit with the first non zero exit code
set -o pipefail
set -x
set -e

# Get our environment
if [ -f /testenv ]
then
	set -a
	source /testenv
	set +a
fi

function finish {
	ec=$?
	if [ $ec == 0 ] ; then ec=1 ; else ec=0 ; fi

	echo "${GRAPHITE_PATH} $ec $(date +%s)" | nc ${NC_OPTS} ${GRAPHITE_EXPORTER_SERVER} 9109
}

trap finish EXIT

# graphite exporter address
GRAPHITE_EXPORTER_SERVER=${GRAPHITE_EXPORTER_SERVER:-"graphite_exporter"}

# where to install from? Install the last stable release by default
DOCKER_INSTALL_DOMAIN=${DOCKER_INSTALL_DOMAIN:-get}

# check for -q support
NC_OPT=""
if [ "$(nc -h 2>&1 | grep -- '-q')" != "" ]
then
	NC_OPTS="-q0"
fi

function get_distrib_name() {
	[ -n "$DOCKER_TARGET_DIST_NAME" ] && echo $DOCKER_TARGET_DIST_NAME && return 0

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

	echo $DIST_NAME
}

function install {
	DOCKER_TARGET_DIST_NAME=$(get_distrib_name)

	GRAPHITE_PATH="test.install.from.${DOCKER_INSTALL_DOMAIN}.docker.com.on.${DOCKER_TARGET_DIST_NAME}"

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
}

install
