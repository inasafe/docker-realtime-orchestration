#!/bin/sh

INASAFE_REALTIME_IMAGE=docker-realtime-inasafe

function build_realtime_image {
    echo "Building InaSAFE Realtime Dockerfile"
    docker build -t aifdr/${INASAFE_REALTIME_IMAGE} .
}

build_realtime_image
