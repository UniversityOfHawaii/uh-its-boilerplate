#!/usr/bin/env bash

#
# echoes the image IDs of every local image matching the given imageTag to
# stdout; exits with status 0 if any matching images exist, status 1 if no
# matches are found
#

if [ $# -ne 1 ]; then
  echo "usage: $0 <imageTag>"
  exit 1
fi

imageTag=$1
imageId=$(docker image ls -q "$imageTag")
if [ "$imageId" != "" ]; then
	echo "$imageId"
  exit 0
else
	exit 1
fi
