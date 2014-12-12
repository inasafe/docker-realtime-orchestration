#!/bin/bash

export EQ_SFTP_USER_NAME=`cat /credentials | cut -d ':' -f 2 | cut -d ' ' -f 2`
export EQ_SFTP_USER_PASSWORD=`cat /credentials | cut -d ':' -f 3 | cut -d ' ' -f 2`
# Will get set for us by docker link
export EQ_SFTP_BASE_URL=${SFTP_LOCAL_IP}
# Will get set for us by docker link
export EQ_SFTP_PORT=${SFTP_LOCAL_PORT}
export EQ_SFTP_BASE_PATH=/home/realtime/shakemaps

cd /home/realtime/src/inasafe
. scripts/realtime/make-latest-shakemap.sh
. scripts/realtime/make-public.sh
