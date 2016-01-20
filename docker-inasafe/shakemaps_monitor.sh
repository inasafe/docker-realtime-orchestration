#!/bin/bash

cd ${INASAFE_SOURCE_DIR}

source run-env-realtime.sh

xvfb-run -a --server-args="-screen 0, 1024x768x24" python realtime/earthquake/notify_new_shake.py $SHAKEMAPS_DIR
