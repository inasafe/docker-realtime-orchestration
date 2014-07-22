#!/bin/bash

function kill_container {
    NAME=$1

    if docker.io ps -a | grep ${NAME} > /dev/null
    then
        echo "Killing ${NAME}"
        docker.io kill ${NAME}
        docker.io rm ${NAME}
    else
        echo "${NAME} is not already running"
    fi
}


function deploy_apache_server {
    echo ""
    echo "Building Apache Server"
    echo "====================================="
    cd ${REALTIME_DIR}
    APACHE_IMAGE=docker-realtime-apache
    docker.io build -t ${ORG}/${APACHE_IMAGE} git://github.com/${ORG}/${APACHE_IMAGE}.git

    echo "Starting Apache Server"
    WEBDIR=/home/realtime/web
    APACHE_IMAGE=docker-realtime-apache

    kill_container ${APACHE_IMAGE}

    if [ ! -d ${WEBDIR} ]
    then
        mkdir -p ${WEBDIR}
    fi

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
    docker.io run --name="${APACHE_IMAGE}" \
        -v $WEBDIR:/var/www \
        -p 8080:80 \
        -d -t ${ORG}/${APACHE_IMAGE}
}

function deploy_sftp_server {
    echo ""
    echo "Building SFTP Server image"
    echo "====================================="
    sudo mkdir ${REALTIME_DIR}
    sudo chown ${USER}.${USER} ${REALTIME_DIR}
    pushd .
    cd ${REALTIME_DIR}
    SFTP_IMAGE=docker-realtime-sftp
    docker.io build -t ${ORG}/${SFTP_IMAGE} git://github.com/${ORG}/${SFTP_IMAGE}.git

    echo "Starting SFTP Server image"
    kill_container  ${SFTP_IMAGE}

    if [ ! -d ${SHAKEDIR} ]
    then
        mkdir -p ${SHAKEDIR}
    fi

    docker.io run --name="${SFTP_IMAGE}" \
        -v ${SHAKEDIR}:/shakemaps \
        -p 9222:22 \
        -d -t ${ORG}/${SFTP_IMAGE}
}


function deploy_btsync_server {
    echo ""
    echo "Setting up btsync server"
    echo "====================================="
    DATADIR=/home/realtime/analysis_data
    BTSYNC_IMAGE=docker-realtime-btsync

    kill_container ${BTSYNC_IMAGE}

    docker.io build -t ${ORG}/${BTSYNC_IMAGE} git://github.com/${ORG}/${BTSYNC_IMAGE}.git

    if [ ! -d ${DATADIR} ]
    then
        mkdir -p ${DATADIR}
    fi

    docker.io run --name="${BTSYNC_IMAGE}" \
        -v $DATADIR:$DATADIR \
        -p 8888:8888 \
        -p 55555:55555 \
        -d -t AIFDR/${BTSYNC_IMAGE}
}


function build_realtime_image {
    echo ""
    echo "Building InaSAFE Realtime"
    echo "====================================="
    cd ${REALTIME_DIR}
    echo "Building InaSAFE Realtime Dockerfile"
    INASAFE_REALTIME_IMAGE=docker-realtime-inasafe
    docker.io build -t ${ORG}/${INASAFE_REALTIME_IMAGE} git://github.com/${ORG}/${INASAFE_REALTIME_IMAGE}.git
}


function show_credentials {
    echo ""
    echo "You can copy files into SFTP container with these credentials:"
    echo "====================================="
    # Note you can run this command any time after the container
    # is started and all containers started will have these
    # same credentials so you should be able to safely destroy
    # and recreate this container
    docker.io cp docker-realtime-sftp:/credentials .
    cat credentials
    rm credentials
}
