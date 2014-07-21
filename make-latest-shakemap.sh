#!/bin/bash

# This will be called by cron job on the host

REALTIME_DIR=/home/realtime
INASAFE_REALTIME_IMAGE=docker-inasafe-realtime

# TODO: Grab the user name and password automatically
# TODO: Mount /home/realtime/data volume
SFTP_LOCAL_IP=$(docker inspect inasafe-realtime-sftp | grep IPAddress | cut -d '"' -f 4)
SFTP_LOCAL_PORT=22
SFTP_USER_NAME=realtime
SFTP_USER_PASSWORD=ieZ4dohn2sab
SFTP_BASE_PATH=/shakemaps

docker.io run --name="inasafe-realtime" \
-e EQ_SFTP_BASE_URL=${SFTP_LOCAL_IP} \
-e EQ_SFTP_PORT=${SFTP_LOCAL_PORT} \
-e EQ_SFTP_USER_NAME=${SFTP_USER_NAME} \
-e EQ_SFTP_USER_PASSWORD=${SFTP_USER_PASSWORD} \
-e EQ_SFTP_BASE_PATH=${SFTP_BASE_PATH} \
-v ${REALTIME_DIR}/shakemaps-cache:${REALTIME_DIR}/shakemaps-cache \
-v ${REALTIME_DIR}/shakemaps-extracted:${REALTIME_DIR}/shakemaps-extracted \
-i -t AIFDR/${INASAFE_REALTIME_IMAGE}

# Kill container right away!
docker.io kill inasafe-realtime
docker.io rm inasafe-realtime
