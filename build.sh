#!/bin/bash

set -e

while getopts ":n" opt; do
  case $opt in
    n)
      echo "INFO: native CPU build requested, run built image on same architecture" >&2
      NATIVE="--enable BUILD_NATIVE"
      ;;
    *)
      echo "Invalid option: -${OPTARG}" >&2
      ;;
  esac
done

DATESTAMP=`date +%Y%m%d%H%M%S`
time docker build \
        --tag=build/asterisk:${DATESTAMP} \
        --build-arg "NATIVE=${NATIVE:-}" \
        -f build.Dockerfile .

CONTAINER=`docker create build/asterisk:${DATESTAMP}`
echo "Created utility container: ${CONTAINER}"

mkdir -p ./tgz
docker cp ${CONTAINER}:/tmp/asterisk.tgz ./tgz/
cd ./tgz
echo "Extracted tgz SHA1: `sha1sum asterisk.tgz`"
cd ${OLDPWD}

RM_CONTAINER=`docker rm -f ${CONTAINER}`
echo "Removed utility container: ${RM_CONTAINER}"

time docker build --tag=local/asterisk:${DATESTAMP} -f asterisk.Dockerfile .
docker tag -f local/asterisk:${DATESTAMP} local/asterisk:latest
rm -rf ./tgz
