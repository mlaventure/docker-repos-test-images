#!/bin/bash

# pipe chain exit with the first non zero exit code
set -o pipefail
set -e
set -x

exit_trap() {
	echo "${DOCKER_INSTALL_DOMAIN}.docker.com 0 $(date +%s)" | nc -q0 ${GRAPHITE_EXPORTER_SERVER} 9109
}

trap exit_trap EXIT

# graphite exporter address
GRAPHITE_EXPORTER_SERVER=${GRAPHITE_EXPORTER_SERVER:-"graphite_exporter"}

DOCKER_INSTALL_DOMAIN=${DOCKER_INSTALL_DOMAIN:-get}

curl -sSL https://${DOCKER_INSTALL_DOMAIN}.docker.com | sh

ec=$?

if [ $ec = 0 ]; then
	echo "${DOCKER_INSTALL_DOMAIN}.docker.com 1 $(date +%s)" | nc -q0 ${GRAPHITE_EXPORTER_SERVER} 9109
else
	echo "${DOCKER_INSTALL_DOMAIN}.docker.com 0 $(date +%s)" | nc -q0 ${GRAPHITE_EXPORTER_SERVER} 9109
fi

exit $ec
