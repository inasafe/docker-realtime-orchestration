#!/bin/bash

get_inasafe() {

    BRANCH_NAME="$1"
    echo ""
    echo "Pulling the latest InaSAFE Realtime from Github."
    echo "================================================"

    if [ ! -d ${INASAFE_SOURCE_DIR} ]
    then
        git clone --branch ${BRANCH_NAME} http://github.com/AIFDR/inasafe.git --depth 1 --verbose ${INASAFE_SOURCE_DIR}
    else
        cd ${INASAFE_SOURCE_DIR}
        git fetch origin
        git checkout ${BRANCH_NAME}
        git pull origin ${BRANCH_NAME}
        cd -
    fi
}

if [ "$1" == "checkout" ];
then
    if [ -n "$2" ];
    then
        get_inasafe "$2"
    else
        echo "ERROR: No branch name passed."
        echo "USAGE: fig run inasafe /start.sh checkout <branch_name>"
    fi
    exit
fi

cd ${INASAFE_SOURCE_DIR}

source run-env-realtime.sh


if [ "$1" == "make-latest-shakemap" ];
then
    echo "make latest shakemap"
    scripts/realtime/make-latest-shakemap.sh ${SHAKEMAPS_DIR}
    scripts/realtime/make-public.sh ${SHAKEMAPS_EXTRACT_DIR} ${WEB_DIR}
    exit
fi

if [ "$1" == "make-all-shakemaps" ];
then
    echo "make all shakemap"
    scripts/realtime/make-all-shakemaps.sh ${SHAKEMAPS_DIR}
    scripts/realtime/make-public.sh ${SHAKEMAPS_EXTRACT_DIR} ${WEB_DIR}
    exit
fi

echo "No recognized command."
echo "Available commands:"
echo " - checkout <branch_name>"
echo " - make-latest-shakemap"
echo " - make-all-shakemaps"
