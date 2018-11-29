#!/bin/bash

if [ $# -ne 2 ]; then
    echo "At least 2 argumnets required!"
    echo "$0 <release> <output files>"
    echo "Example: $0 current linux-*.deb"
    exit 1
fi

VYOS_RELEASE="$1"
FILES="$2"

ARCH=`dpkg --print-architecture`
VYOS_REPO_PATH="/home/sentrium/web/dev.packages.vyos.net/public_html/repositories/${VYOS_RELEASE}/vyos"
SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
SSH_PATH="~/VyOS/${VYOS_RELEASE}/${ARCH}"
SSH_HOST="khagen@dev.packages.vyos.net"

exit_code () {
    rc=$?
    if [[ $rc != 0 ]]; then
        exit $rc
    fi
}

ssh ${SSH_OPTS} ${SSH_HOST} -t "bash --login -c 'mkdir -p ${SSH_PATH}'"
exit_code

scp ${SSH_OPTS} ${FILES} ${SSH_HOST}:${SSH_PATH}
exit_code

for PACKAGE in `ls ${FILES}`;
do
    PACKAGE=`echo ${PACKAGE} | cut -d'/' -f 2`
    SUBSTRING=`echo ${PACKAGE} | cut -d'_' -f 1`
    if [[ "${PACKAGE}" == *_all* ]]; then
        ssh ${SSH_OPTS} ${SSH_HOST} -t "echo 'reprepro -v -b ${VYOS_REPO_PATH} remove ${VYOS_RELEASE} ${SUBSTRING}' | at -q b -v now"
        exit_code
    else
        ssh ${SSH_OPTS} ${SSH_HOST} -t "echo 'reprepro -v -b ${VYOS_REPO_PATH} -A ${ARCH} remove ${VYOS_RELEASE} ${SUBSTRING}' | at -q b -v now"
        exit_code
    fi
    ssh ${SSH_OPTS} ${SSH_HOST} -t "echo 'reprepro -v -b ${VYOS_REPO_PATH} deleteunreferenced' | at -q b -v now"
    exit_code
    if [[ "${PACKAGE}" == *_all* ]]; then
        ssh ${SSH_OPTS} ${SSH_HOST} -t "echo 'reprepro -v -b ${VYOS_REPO_PATH} includedeb ${VYOS_RELEASE} ${SSH_PATH}/${PACKAGE}' | at -q b -v now"
        exit_code
    else
        ssh ${SSH_OPTS} ${SSH_HOST} -t "echo 'reprepro -v -b ${VYOS_REPO_PATH} -A ${ARCH} includedeb ${VYOS_RELEASE} ${SSH_PATH}/${PACKAGE}' | at -q b -v now"
        exit_code
    fi
done
