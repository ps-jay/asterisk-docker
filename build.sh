#!/bin/bash

set -e

DATESTAMP=`date +%Y%m%d%H%M%S`
mkdir -p ./tgz
time docker build --tag=build/asterisk:${DATESTAMP} -f build.Dockerfile .

CONTAINER=`docker create build/asterisk:${DATESTAMP}`
echo "Created utility container: ${CONTAINER}"

docker cp ${CONTAINER}:/tmp/asterisk.tgz ./tgz/
cd ./tgz
echo "Extracted tgz SHA1: `sha1sum asterisk.tgz`"
cd ${OLDPWD}

RM_CONTAINER=`docker rm -f ${CONTAINER}`
echo "Removed utility container: ${RM_CONTAINER}"

time docker build --tag=local/asterisk:${DATESTAMP} -f asterisk.Dockerfile .
docker tag -f local/asterisk:${DATESTAMP} local/asterisk:latest
rm -rf ./tgz
