#!/bin/bash

USER=realtime
REALTIME_DIR=/home/realtime
REALTIME_DATA_DIR=/home/realtime/data
SHAKEDIR=/home/realtime/shakemaps

echo "This script will deploy InaSAFE realtime"
echo "in a series of docker containers"
echo "----------------------------------------"

# ----------------------- Deploying SFTP Server ---------------------- #
echo "Building SFTP Server image"
sudo mkdir $REALTIME_DIR
sudo chown ${USER}.${USER} ${REALTIME_DIR}
pushd .
cd ${REALTIME_DIR}
SFTP_IMAGE=docker-realtime-sftp
docker.io build -t AIFDR/${SFTP_IMAGE} git://github.com/AIFDR/${SFTP_IMAGE}.git

echo "Starting SFTP Server image"
docker.io kill inasafe-realtime-sftp
docker.io rm inasafe-realtime-sftp

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
# ----------------------- End of Deploying SFTP Server --------------------- #

# ----------------------- Deploying InaSAFE Realtime ---------------------- #
echo "Building InaSAFE Realtime"
cd ${REALTIME_DIR}

echo "Downloading some resources needed"
if [ -f "${REALTIME_DATA_DIR}/population.tif" ]
then
    cp ${REALTIME_DATA_DIR}/population.tif .
else
    wget -O ${REALTIME_DATA_DIR}/population.tif http://quake.linfiniti.com/population.tif
fi

if [ -f "${REALTIME_DATA_DIR}/population.keywords" ]
then
    cp ${REALTIME_DATA_DIR}/population.keywords .
else
    wget -O ${REALTIME_DATA_DIR}/population.keywords http://quake.linfiniti.com/population.keywords
fi

if [ -f "${REALTIME_DATA_DIR}/indonesia.sqlite" ]
then
    cp ${REALTIME_DATA_DIR}/indonesia.sqlite .
else
    wget -O ${REALTIME_DATA_DIR}/indonesia.sqlite http://quake.linfiniti.com/indonesia.sqlite
fi

echo "Building InaSAFE Realtime Dockerfile"
INASAFE_REALTIME_IMAGE=docker-inasafe-realtime
docker.io build -t AIFDR/${INASAFE_REALTIME_IMAGE} git://github.com/AIFDR/${INASAFE_REALTIME_IMAGE}.git

# Clean this dir again
rm indonesia.sqlite population.tif population.keywords
# ----------------------- End of Deploying InaSAFE Realtime----------------- #

# ----------------------- Deploying Apache ---------------------- #
echo "Building Apache Server"
cd ${REALTIME_DIR}
APACHE_IMAGE=docker-realtime-apache
docker.io build -t AIFDR/${APACHE_IMAGE} git://github.com/AIFDR/${APACHE_IMAGE}.git

echo "Starting Apache Server"
WEBDIR=/home/realtime/web
APACHE_IMAGE=docker-realtime-apache

docker.io kill inasafe-realtime-apache
docker.io rm inasafe-realtime-apache

mkdir -p $WEBDIR
cp web/index.html ${WEBDIR}/
cp -r web/resource ${WEBDIR}/
# Uncomment to run with a bash prompt for testing
# You can start apache inside the container using
# apache2ctl -D FOREGROUND

#docker.io run --name='inasafe-realtime-apache' \
#	-v $WEBDIR:/var/www \
#	-p 8080:80 \
#        --entrypoint=/bin/bash \
#	-i -t AIFDR/apache-realtime -i

# Once testing is done comment the above and use
# this one rather.
docker.io run --name='inasafe-realtime-apache' \
	-v $WEBDIR:/var/www \
        -p 8080:80 \
	-d -t AIFDR/${APACHE_IMAGE}
# ----------------------- End of Deploying Apache ---------------------- #
