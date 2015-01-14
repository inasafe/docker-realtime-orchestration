#!/bin/bash

INASAFE_SOURCE_DIR=/home/realtime/src/inasafe

function get_inasafe {

    echo ""
    echo "Pulling the latest InaSAFE Realtime from Github."
    echo "================================================"

    if [ ! -d ${INASAFE_SOURCE_DIR} ]
    then
        git clone --branch develop http://github.com/AIFDR/inasafe.git --depth 1 --verbose ${INASAFE_SOURCE_DIR}
    else
        cd ${INASAFE_SOURCE_DIR}
        git fetch origin
        git checkout develop
        git pull origin develop
        cd -
    fi
}

if [ "$1" == "checkout" ]
then
    get_inasafe
    exit
fi

cd ${INASAFE_SOURCE_DIR}
scripts/realtime/make-latest-shakemap.sh
scripts/realtime/make-public.sh
