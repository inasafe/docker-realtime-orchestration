#!/bin/bash

echo "This script will deploy InaSAFE realtime"
echo "in a series of docker containers"
echo "----------------------------------------"


function download_analysis_data {
    echo "Downloading Analysis Data"
    analysis_data=( population.tif population.keywords indonesia.sqlite )
    for data in "${analysis_data[@]}"
    do
        if ! [ -f "${REALTIME_DATA_DIR}/${data}" ]
        then
            wget -c -O ${REALTIME_DATA_DIR}/${data} http://quake.linfiniti.com/${data}
        fi
    done
}

function deploy_sftp_server {
    echo "Building SFTP Server image"
    sudo mkdir ${REALTIME_DIR}
    sudo chown ${USER}.${USER} ${REALTIME_DIR}
    pushd .
    cd ${REALTIME_DIR}
    SFTP_IMAGE=docker-realtime-sftp
    docker.io build -t ${ORG}/${SFTP_IMAGE} git://github.com/${ORG}/${SFTP_IMAGE}.git

    echo "Starting SFTP Server image"
    docker.io kill inasafe-realtime-sftp
    docker.io rm inasafe-realtime-sftp

    mkdir -p ${SHAKEDIR}
    docker.io run --name='inasafe-realtime-sftp' \
        -v ${SHAKEDIR}:/shakemaps \
        -p 9222:22 \
        -d -t ${ORG}/${SFTP_IMAGE}
}


function build_realtime_image {
    echo "Building InaSAFE Realtime"
    cd ${REALTIME_DIR}

    echo "Building InaSAFE Realtime Dockerfile"
    INASAFE_REALTIME_IMAGE=docker-inasafe-realtime
    docker.io build -t ${ORG}/${INASAFE_REALTIME_IMAGE} git://github.com/${ORG}/${INASAFE_REALTIME_IMAGE}.git
}

function deploy_apache_server {
    echo "Building Apache Server"
    cd ${REALTIME_DIR}
    APACHE_IMAGE=docker-realtime-apache
    docker.io build -t ${ORG}/${APACHE_IMAGE} git://github.com/${ORG}/${APACHE_IMAGE}.git

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
    #	--entrypoint=/bin/bash \
    #	-i -t ${ORG}/apache-realtime -i

    # Once testing is done comment the above and use
    # this one rather.
    docker.io run --name='inasafe-realtime-apache' \
        -v $WEBDIR:/var/www \
        -p 8080:80 \
        -d -t ${ORG}/${APACHE_IMAGE}
}

function show_credentials {

    echo "You can copy files into SFTP container with these credentials:"
    # Note you can run this command any time after the container
    # is started and all containers started will have these
    # same credentials so you should be able to safely destroy
    # and recreate this container
    docker cp inasafe-realtime-sftp:/credentials .
    cat credentials
    rm credentials
}

# See if we are using forks or official repo
if test -z "$1"
then
  echo "Using ${ORG} organsiation repos on github"
  export ORG=${ORG}
else
  echo "Using personal forks: $1"
  export ORG=$1
fi


USER=realtime
REALTIME_DIR=/home/realtime
REALTIME_DATA_DIR=/home/realtime/data
SHAKEDIR=/home/realtime/shakemaps

download_analysis_data
deploy_apache_server
deploy_sftp_server
build_realtime_image
show_credentials
