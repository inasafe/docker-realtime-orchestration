#!/bin/bash

while true;
do
    inotifywait -e create $1 | while read FILE
    do
        FOLDER=$(echo "$FILE" | cut -f 3 -d ' ')
        echo "Create event found"
        echo "$(date)"
        echo "$FOLDER is created"
        echo ""

        # notify REALTIME REST that a shakemap is pushed
        cd ${INASAFE_SOURCE_DIR}

        source run-env-realtime.sh

        python realtime/notify_new_shake.py $SHAKEMAPS_DIR $FOLDER
    done
done
