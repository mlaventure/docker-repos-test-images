#!/bin/bash

# pipe chain exit with the first non zero exit code
set -o pipefail
set -x

# which repo are we testing?
DOCKER_INSTALL_REPO_TYPE=${DOCKER_INSTALL_REPO_TYPE:-apt}

# graphite exporter address
GRAPHITE_EXPORTER_SERVER=${GRAPHITE_EXPORTER_SERVER:-"graphite_exporter"}

# where to install from? Install the last stable release by default
DOCKER_INSTALL_DOMAIN=${DOCKER_INSTALL_DOMAIN:-get}

# how long to wait between each retry? 1h by default
DOCKER_INSTALL_TEST_INTERVAL=${DOCKER_INSTALL_TEST_INTERVAL:-1h}

curl -sSL https://${DOCKER_INSTALL_DOMAIN}.docker.com | sh

ec=$?
if [ $ec = 0 ]; then
	echo "${DOCKER_INSTALL_REPO_TYPE}.test.install.from.${DOCKER_INSTALL_DOMAIN}.docker.com 1 $(date +%s)" | nc -q0 ${GRAPHITE_EXPORTER_SERVER} 9109
else
	echo "${DOCKER_INSTALL_REPO_TYPE}.test.install.from.${DOCKER_INSTALL_DOMAIN}.docker.com 0 $(date +%s)" | nc -q0 ${GRAPHITE_EXPORTER_SERVER} 9109
fi

sleep ${DOCKER_INSTALL_TEST_INTERVAL}

exit $ec
