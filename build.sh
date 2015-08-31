#!/bin/bash

set -e

mkdir -p ./tgz
docker build --tag=build/asterisk -f build.Dockerfile .

CONTAINER=`docker run -d build/asterisk`
echo "Running utility container: ${CONTAINER}"

docker cp ${CONTAINER}:/tmp/asterisk.tgz ./tgz/
cd ./tgz
echo "SHA1: `sha1sum asterisk.tgz`"
cd ${OLDPWD}

RM_CONTAINER=`docker rm -f ${CONTAINER}`
echo "Removed utility container: ${RM_CONTAINER}"
