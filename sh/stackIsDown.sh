#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <stackName>"
  exit 1
fi

FORMAT="{{.Name}}"
stackName=$1

pau=-1
waited=0

# wait until stack is down
until [ $pau -eq 0 ]; do
  docker stack ls --format "$FORMAT" | grep -q "$stackName"
  stackStatus=$?
  if [ $stackStatus -ne 0 ]; then
    # verify network has been cleaned up
    docker network ls --format "$FORMAT" | grep -q "${stackName}_default"
    netStatus=$?
    if [ $netStatus -ne 0 ]; then
      pau=0
    fi
  fi

  if [ $waited -eq 0 ]; then
    printf "waiting"
    waited=1
  else
    printf "."
  fi
  sleep 1
done
printf "\nstack %s is down\n" "$stackName"
