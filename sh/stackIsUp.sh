#!/usr/bin/env bash

if [ $# -ne 1 ]; then
  echo "usage: $0 <stackName>"
  exit 1
fi

FORMAT="{{.Name}}"
stackName=$1

COMPLETED="completed"
pau=-1
waited=0

# wait until has completed launching
until [ $pau -eq 0 ]; do
  docker stack ls --format $FORMAT | grep -q "$stackName"
  stackStatus=$?
  if [ $stackStatus -eq 0 ]; then
    # verify services have completed startup: all 'replicas' counts
    # should be of the form N/N, indicating that all desired replicas
    # for each service have completed startup
    for PAIR in $(docker stack services "$stackName" --format '{{.Replicas}}'); do
      servicesReplicated=$COMPLETED

      # shellcheck disable=SC2162
      IFS='/' read -a values <<< "$PAIR"
      if [ "${values[0]}" != "${values[1]}" ]; then
        servicesReplicated="waiting"
      fi
    done
    if [ $servicesReplicated == $COMPLETED ]; then
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
printf "\nstack %s is up\n" "$stackName"
