#!/bin/bash

REALTIME_DIR=/home/realtime
cd $REALTIME_DIR

USER_ID=`ls -lahn | grep 'shakemaps$' | awk {'print $3'}`
GROUP_ID=`ls -lahn | grep 'shakemaps$' | awk {'print $4'}`

usermod -u ${USER_ID} realtime
groupmod -g ${GROUP_ID} realtime

/usr/sbin/sshd -D
