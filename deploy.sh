#!/bin/bash
source functions.sh

echo ""
echo "----------------------------------------"
echo "This script will deploy InaSAFE realtime"
echo "in a series of docker containers"
echo "----------------------------------------"
echo ""


# See if we are using forks or official repo
if test -z "$1"
then
  echo "Using ${ORG} organsiation repos on github"
  export ORG=AIFDR
else
  echo "Using personal forks: $1"
  export ORG=$1
fi


USER=realtime
REALTIME_DIR=/home/realtime
REALTIME_DATA_DIR=/home/realtime/analysis_data
SHAKEDIR=/home/realtime/shakemaps

deploy_apache_server
deploy_sftp_server
deploy_btsync_server
build_realtime_image
show_credentials
