#!/bin/sh

INASAFE_REALTIME_IMAGE=docker-realtime-inasafe

function build_realtime_image {
    echo "Building InaSAFE Realtime Dockerfile"
    docker build -t kartoza/${INASAFE_REALTIME_IMAGE}:2.4 .
}

build_realtime_image
