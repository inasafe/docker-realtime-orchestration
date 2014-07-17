#!/bin/bash

REALTIME_DIR=/home/realtime
SHAKEDIR=/home/realtime/shakemaps

echo "This script will deploy InaSAFE realtime"
echo "in a series of docker containers"

echo "Building SFTP Server image"
sudo mkdir $REALTIME_DIR
sudo chown ${USER}.${USER} ${REALTIME_DIR}
pushd .
cd $(REALTIME_DIR}
SFTP_IMAGE=docker-realtime-sftp
docker.io build -t AIFDR/${SFTP_IMAGE} git://github.com/AIFDR/${SFTP_IMAGE}.git

echo "Starting SFTP Server image"
mkdir -p $SHAKEDIR
docker.io run --name='inasafe-realtime-sftp' \
	-v $SHAKEDIR:/shakemaps \
	-p 9222:22 \
	-d -t AIFDR/sftp-realtime

echo "You can copy files into this container with these credentials:"
# Note you can run this command any time after the container 
# is started and all containers started will have these
# same credentials so you should be able to safely destroy 
# and recreate this container

docker cp inasafe-realtime-sftp:/credentials .
cat credentials
rm credentials

