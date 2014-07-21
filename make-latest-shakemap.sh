#!/bin/bash

# This will be called by cron job on the host

REALTIME_DIR=/home/realtime
INASAFE_REALTIME_IMAGE=docker-inasafe-realtime

# TODO AG: Not finished, should run the script: scripts/realtime/make-latest-shakemap
# TODO     inside the container under /home/realtime/src/inasafe
# TODO AG: pass some env variables for this container related to sftp config
docker.io run --name="inasafe-realtime" \
-p 2222:22 \
--link sftp-realtime:sftp-realtime \
-v ${REALTIME_DIR}/shakemaps-cache:${REALTIME_DIR}/shakemaps-cache \
-v ${REALTIME_DIR}/shakemaps-extracted:${REALTIME_DIR}/shakemaps-extracted \
-t AIFDR/${INASAFE_REALTIME_IMAGE}

# Kill container right away!
docker.io kill inasafe-realtime
docker.io rm inasafe-realtime
