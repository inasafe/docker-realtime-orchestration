#!/bin/bash

source /home/realtime/src/inasafe/run-env-realtime.sh /usr

# variable export

export DISPLAY=:99

export INSAFE_REALTIME_TEMPLATE=/home/realtime/analysis_data/realtime-template.qpt
export INSAFE_REALTIME_PROJECT=/home/realtime/analysis_data/realtime.qgs
export INASAFE_POPULATION_PATH=/home/realtime/analysis_data/exposure/population.tif
export INASAFE_FLOOD_POPULATION_PATH=/home/realtime/analysis_data/exposure/population_jakarta_clipped.tif
export GEONAMES_SQLITE_PATH=/home/realtime/analysis_data/indonesia.sqlite
export INASAFE_SOURCE_DIR=/home/realtime/src/inasafe
export SHAKEMAPS_DIR=/home/realtime/shakemaps
export SHAKEMAPS_EXTRACT_DIR=/home/realtime/shakemaps-extracted
export FLOODMAPS_DIR=/home/realtime/floodmaps
export WEB_DIR=/var/www
export C_FORCE_ROOT=True
export INASAFE_REALTIME_BROKER_HOST=amqp://guest:guest@rabbitmq:5672/
