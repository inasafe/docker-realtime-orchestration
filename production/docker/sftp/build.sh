#!/usr/bin/env bash

REPO_NAME=kartoza
IMAGE_NAME=realtime-orchestration_sftp
TAG_NAME=v3.0
docker build -t ${REPO_NAME}/${IMAGE_NAME} .
docker tag ${REPO_NAME}/${IMAGE_NAME} ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
docker push ${REPO_NAME}/${IMAGE_NAME}:${TAG_NAME}
