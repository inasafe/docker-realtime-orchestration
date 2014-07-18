#!/bin/bash

REALTIME_DIR=/home/realtime
REALTIME_DATA_DIR=/home/realtime/data
SHAKEDIR=/home/realtime/shakemaps

echo "This script will deploy InaSAFE realtime"
echo "in a series of docker containers"
echo "----------------------------------------"

echo "Building SFTP Server image"
sudo mkdir $REALTIME_DIR
sudo chown ${USER}.${USER} ${REALTIME_DIR}
pushd .
cd ${REALTIME_DIR}
SFTP_IMAGE=docker-realtime-sftp
docker.io build -t AIFDR/${SFTP_IMAGE} git://github.com/AIFDR/${SFTP_IMAGE}.git

echo "Starting SFTP Server image"
mkdir -p $SHAKEDIR
docker.io run --name='inasafe-realtime-sftp' \
	-v $SHAKEDIR:/shakemaps \
	-p 9222:22 \
	-d -t AIFDR/${SFTP_IMAGE}

echo "You can copy files into this container with these credentials:"
# Note you can run this command any time after the container
# is started and all containers started will have these
# same credentials so you should be able to safely destroy
# and recreate this container

docker cp inasafe-realtime-sftp:/credentials .
cat credentials
rm credentials

echo "Building InaSAFE Realtime"
cd ${REALTIME_DIR}

echo "Downloading some resources needed"

if [ -f "${REALTIME_DATA_DIR}/population.tif" ]
then
    cp ${REALTIME_DATA_DIR}/population.tif .
else
    wget -c http://quake.linfiniti.com/population.tif
fi

if [ -f "${REALTIME_DATA_DIR}/population.keywords" ]
then
    cp ${REALTIME_DATA_DIR}/population.keywords .
else
    wget -c http://quake.linfiniti.com/population.keywords
fi

if [ -f "${REALTIME_DATA_DIR}/indonesia.sqlite" ]
then
    cp ${REALTIME_DATA_DIR}/indonesia.sqlite .
else
    wget -c http://quake.linfiniti.com/indonesia.sqlite
fi

echo "Building InaSAFE Realtime Dockerfile"
cd ${REALTIME_DIR}
INASAFE_REALTIME_IMAGE=docker-inasafe-realtime
docker.io build -t AIFDR/${INASAFE_REALTIME_IMAGE} git://github.com/AIFDR/${INASAFE_REALTIME_IMAGE}.git

# Clean this dir again
rm indonesia.sqlite population.tif population.keywords


