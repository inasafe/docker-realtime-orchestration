#!/bin/bash

get_inasafe() {

    BRANCH_NAME="$1"
    echo ""
    echo "Pulling the latest InaSAFE Realtime from Github."
    echo "================================================"

    if [ ! -d ${INASAFE_SOURCE_DIR} ]
    then
        git clone --branch ${BRANCH_NAME} http://github.com/inasafe/inasafe-realtime.git --depth 1 --verbose ${INASAFE_SOURCE_DIR}
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

if [ "$1" == "make-latest-floodmap" ];
then
	echo "make latest floodmap"
	scripts/realtime/make-latest-floodmap.sh ${FLOODMAPS_DIR}
	exit
fi

if [ "$1" == "celery-workers" ];
then
	# Checking celery config
	if [ ! -f headless/celeryconfig.py ]; then
		"Use default headless/celeryconfig"
		cp headless/celeryconfig_sample.py headless/celeryconfig.py
	fi

	if [ ! -f realtime/celeryconfig.py ]; then
		"Use default realtime/celeryconfig"
		cp realtime/celeryconfig_sample.py realtime/celeryconfig.py
	fi


	echo "Running celery worker for realtime"
	xvfb-run --server-args="-screen 0, 1024x768x24" celery -A realtime.celery_app worker -l info -Q inasafe-realtime
	exit
fi

if [ "$1" == "shakemaps-monitor" ];
then
	echo "Running shakemaps monitoring"
	/shakemaps_monitor.sh
	exit
fi

echo "No recognized command."
echo "Available commands:"
echo " - checkout <branch_name>"
echo " - make-latest-shakemap"
echo " - smake-all-shakemaps"
echo " - celery-workers"
echo " - shakemaps-monitor"
