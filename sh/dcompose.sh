#!/usr/bin/env bash

usage() {
  cat << EOUSAGE

Usage: $0 [-h | flags]
  -h
    detailed help information, describing all recognized flags (both
    optional and required)

  flags:
    runs a docker-compose command, with additional preprocessing as described
    in the detailed help information

EOUSAGE

  exit 1
}

# help is a reserved word
helpx() {
  cat << EOHELP

Usage: $0 [flags]
  runs a docker-compose command, with additional parameter preprocessing

  Required flags:
  -s <serviceName>
      name of primary service defined in compose file

  -f <composeFile>
      path to compose file; -f option may be repeated multiple times

  -c <command>
      docker-compose command to invoke on the given files

  -p <projectName>
      project name

  -i <imageName>
      image-name passed in to the compose file

  Optional flags:
  -d
      prints the docker-compose command which would normally be executed,
      without actually executing it

  -r <registry>
      registry where the image is/will be located;
      defaults to local (i.e. blank)

EOHELP

  exit 1
}

###
# script parameters
###

#
# initialize option-values
DEBUG=0
FILE_LIST=
BUILD_VERSION=
REGISTRY=
IMAGE_NAME=
PROJECT_NAME=

#
# define recognized options
optstring=":dhs:f:c:p:b:r:i:"
# leading : tells getopt to not emit error messages; everything else defines a
# one-character option with an argument
while getopts "$optstring" options; do
  case "${options}" in
    d)
      DEBUG=1
      ;;
    h)
      helpx
      ;;
    f)
      FILE_LIST+="--file ${OPTARG} "
      ;;
    p)
      PROJECT_NAME=${OPTARG}
      ;;
    b)
      BUILD_VERSION=${OPTARG}
      ;;
    r)
      REGISTRY=${OPTARG}
      ;;
    i)
      IMAGE_NAME=${OPTARG}
      ;;
    :)
      # complain about missing required arguments
      printf "option '-%s' requires an argument\n" "$OPTARG"
      usage
      ;;
    *)
      # complain about unrecognized options
      printf "unrecognized option '%s'\n" "$options"
      usage
      ;;
  esac
done

#
# validate params
## complain about missing required params
broken=0
if [ "$FILE_LIST" == "" ]; then
  printf "missing required compose file(s)\n"
  broken=1
fi
if [ "$PROJECT_NAME" == "" ]; then
  printf "missing required project name\n"
  broken=1
fi
if [ "$IMAGE_NAME" == "" ]; then
  printf "image name must not be blank\n"
  broken=1
fi
if [ "$BUILD_VERSION" == "" ]; then
  printf "build version must not be blank\n"
  broken=1
fi
if [ "$REGISTRY" != "" ]; then
  if ! [[ "$REGISTRY" =~ ^.*/$ ]] ; then
    printf "registry must either be blank, or end with a /\n"
    broken=1
  fi
fi

if [ $broken -eq 1 ]; then
  usage
fi

#
# remove processed params
shift $((OPTIND-1))

#
# do the thing
#

if [ $DEBUG -eq 1 ]; then
  echo "BUILD_VERSION=${BUILD_VERSION} REGISTRY=${REGISTRY} IMAGE_NAME=${IMAGE_NAME} docker-compose --project-name ${PROJECT_NAME} ${FILE_LIST} $@"
  exit 0
fi

# shellcheck disable=SC2086
BUILD_VERSION=${BUILD_VERSION} REGISTRY=${REGISTRY} IMAGE_NAME=${IMAGE_NAME} docker-compose --project-name ${PROJECT_NAME} ${FILE_LIST} "$@"
