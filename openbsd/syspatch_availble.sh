#!/bin/sh

# This script lets you do a syspatch -c to see if there are any syspatches
# available for you OpenBSD server. If there are any, POST a message to your
# specified Matrix room notifying that there are syspatches available.

# This script will contain confidential info, so either keep this in a safe
# place with secure permissions, or place the info in read-only files and
# `cat` the info into the INTERNAL_ROOM_ID and ACCESS_TOKEN variables.

# Obtain the INTERNAL_ROOM_ID - the room where you will receive notifications.
# Go to the room -> Room Info -> Room settings -> Advanced -> Internal room ID.
# Copy/paste that value into the INTERNAL_ROOM_ID variable

# ACCESS_TOKEN - the authentication token for the room. This will be the token
# that YOUR user uses to send messages. It is HIGHLY recommended that you
# do not use your primary account for this sort of messaging.
# Go to All Settings -> Help & About -> Advanced -> Access Token

# Matrix homeserver
MATRIX_SERVER="matrix.org"
#NOTE You may have to change ! to %21 and : to %3A
INTERNAL_ROOM_ID=""
ACCESS_TOKEN=""
MESSAGE_BODY="$(hostname) syspatch available"

if [ ! -z "$(syspatch -c)" ]; then
	body="{\"body\":\"$MESSAGE_BODY\",\"msgtype\":\"m.text\"}"
	contentlength=$(expr $(echo "$body" | wc -m) - 1)

	head="POST /_matrix/client/r0/rooms/$INTERNAL_ROOM_ID/send/m.room.message?access_token=$ACCESS_TOKEN HTTP/1.1\r\nHost: $MATRIX_SERVER\r\nContent-Type: application/json\r\nContent-Length: $contentlength\r\n\r\n$body"

	echo -ne "$head" | nc -c $MATRIX_SERVER 443
fi
