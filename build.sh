#!/bin/bash

set -e

DATESTAMP=`date +%Y%m%d%H%M%S`
mkdir -p ./tgz
time docker build --tag=build/asterisk:${DATESTAMP} -f build.Dockerfile .

CONTAINER=`docker run -d build/asterisk:${DATESTAMP}`
echo "Running utility container: ${CONTAINER}"

docker cp ${CONTAINER}:/tmp/asterisk.tgz ./tgz/
cd ./tgz
echo "SHA1: `sha1sum asterisk.tgz`"
cd ${OLDPWD}

RM_CONTAINER=`docker rm -f ${CONTAINER}`
echo "Removed utility container: ${RM_CONTAINER}"
