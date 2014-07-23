#!/bin/bash
source functions.sh

echo ""
echo "----------------------------------------"
echo "This script will deploy InaSAFE realtime"
echo "images as a series of docker containers"
echo "----------------------------------------"
echo ""

run_apache_container
run_sftp_server_container
run_btsync_container
show_credentials


