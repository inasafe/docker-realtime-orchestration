#!/bin/sh

source functions.sh

# This if for development so that we can ssh into it

SFTP_LOCAL_IP=$(docker.io inspect inasafe-realtime-sftp | grep IPAddress | cut -d '"' -f 4)
SFTP_LOCAL_PORT=22
SFTP_USER_NAME=$(show_credentials | cut -d ':' -f 2 | cut -d ' ' -f 2)
SFTP_USER_PASSWORD=$(show_credentials | cut -d ':' -f 3 | cut -d ' ' -f 2)
SFTP_BASE_PATH=/shakemaps

INSAFE_REALTIME_TEMPLATE=${REALTIME_DATA_DIR}/realtime-template.qpt
INSAFE_REALTIME_PROJECT=${REALTIME_DATA_DIR}/realtime.qgs
INASAFE_POPULATION_PATH=${REALTIME_DATA_DIR}/exposure/population.tif
GEONAMES_SQLITE_PATH=${REALTIME_DATA_DIR}/indonesia.sqlite

docker.io run --name="inasafe-realtime" \
-e EQ_SFTP_BASE_URL=${SFTP_LOCAL_IP} \
-e EQ_SFTP_PORT=${SFTP_LOCAL_PORT} \
-e EQ_SFTP_USER_NAME=${SFTP_USER_NAME} \
-e EQ_SFTP_USER_PASSWORD=${SFTP_USER_PASSWORD} \
-e EQ_SFTP_BASE_PATH=${SFTP_BASE_PATH} \
-e INSAFE_REALTIME_TEMPLATE=${INSAFE_REALTIME_TEMPLATE} \
-e INSAFE_REALTIME_PROJECT=${INSAFE_REALTIME_PROJECT} \
-e INASAFE_POPULATION_PATH=${INASAFE_POPULATION_PATH} \
-e GEONAMES_SQLITE_PATH=${GEONAMES_SQLITE_PATH} \
-v ${REALTIME_DATA_DIR}:${REALTIME_DATA_DIR} \
-v ${REALTIME_DIR}/shakemaps-cache:${REALTIME_DIR}/shakemaps-cache \
-v ${REALTIME_DIR}/shakemaps-extracted:${REALTIME_DIR}/shakemaps-extracted \
-i -t AIFDR/${INASAFE_REALTIME_IMAGE}

# Kill the container right away
kill_container inasafe-realtime
