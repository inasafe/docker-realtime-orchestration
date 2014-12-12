#!/bin/bash

export EQ_SFTP_USER_NAME=realtime
export EQ_SFTP_USER_PASSWORD=jea4Mighaif0
#export EQ_SFTP_USER_PASSWORD=`cat /credentials | cut -d ':' -f 3 | cut -d ' ' -f 2`
# Will get set for us by docker link
export EQ_SFTP_BASE_URL=${SFTP_PORT_22_TCP_ADDR}
# Will get set for us by docker link
export EQ_SFTP_PORT=22
export EQ_SFTP_BASE_PATH=/home/realtime/shakemaps

INASAFE_SOURCE_DIR=/home/realtime/src/inasafe

function get_inasafe {

    echo ""
    echo "Pulling the latest InaSAFE Realtime from Github."
    echo "================================================"

    if [ ! -d ${INASAFE_SOURCE_DIR} ]
    then
        git clone --branch realtime http://github.com/AIFDR/inasafe.git --depth 1 --verbose ${INASAFE_SOURCE_DIR}
    else
        cd ${INASAFE_SOURCE_DIR}
        git pull origin realtime
        cd -
    fi
}

if [ "$1" == "checkout" ]
then
    get_inasafe
    exit
fi

cd ${INASAFE_SOURCE_DIR}
. scripts/realtime/make-latest-shakemap.sh
. scripts/realtime/make-public.sh
