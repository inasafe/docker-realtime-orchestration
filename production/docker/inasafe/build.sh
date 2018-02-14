#!/usr/bin/env bash

if [ -z "$REPO_NAME" ]; then
	REPO_NAME=kartoza
fi

if [ -z "$IMAGE_NAME" ]; then
	IMAGE_NAME=realtime-orchestration_inasafe
fi

if [ -z "$TAG_NAME" ]; then
	TAG_NAME=latest
fi

if [ -z "$BUILD_ARGS" ]; then
	BUILD_ARGS="--pull --no-cache"
fi

# Build Args Environment

if [ -z "$INASAFE_REALTIME_TAG" ]; then
	INASAFE_REALTIME_TAG=realtime-backport-cherry-pick
fi

echo "INASAFE_REALTIME_TAG=${INASAFE_REALTIME_TAG}"

echo "Build: $REPO_NAME/$IMAGE_NAME:$TAG_NAME"
echo "Build Args: $BUILD_ARGS"

docker build -t ${REPO_NAME}/${IMAGE_NAME} ${BUILD_ARGS} \
	--build-arg INASAFE_REALTIME_TAG=${INASAFE_REALTIME_TAG} \
	${BUILD_ARGS} .
docker tag ${REPO_NAME}/${IMAGE_NAME} ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
docker push ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
