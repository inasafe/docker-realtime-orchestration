#!/bin/bash
REPO_NAME=kartoza
IMAGE_NAME=realtime-orchestration_inasafe
TAG_NAME=latest

if [ -z $INASAFE_REALTIME_TAG ]; then
	INASAFE_REALTIME_TAG=realtime-backport-cherry-pick
fi
echo "INASAFE_REALTIME_TAG=${INASAFE_REALTIME_TAG}"

echo "Build: $REPO_NAME/$IMAGE_NAME:$TAG_NAME"

docker build -t ${REPO_NAME}/${IMAGE_NAME} .
docker tag ${REPO_NAME}/${IMAGE_NAME} ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
docker push${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
