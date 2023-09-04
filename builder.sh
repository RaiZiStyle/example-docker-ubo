#!/bin/bash

# Color options :
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)

SHORT=p:,h
LONG=php-full-version:,help
OPTS=$(getopt -a -n weather --options $SHORT --longoptions $LONG -- "$@")

eval set -- "$OPTS"

usage() {
  printf "Usage of builder.sh : ./builder -p FULL_VERSION_PHP\n"
  printf "\tExample : ./builder.sh -p 8.1.19 # Will build for php version 8.1.19\n"
  printf "\tExample : ./builder.sh -p 8.2.1 # Will build for php version 8.2.1\n"
  exit 1

}

while :; do
  case "$1" in
  -p | --php-full-version)
    FULL_PHP_VERSION="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "Unexpected option: $1"
    ;;
  esac
done

DOCKER_ARG_FULL_PHP_VERSION="FULL_PHP_VERSION=${FULL_PHP_VERSION}"                               # Result
DOCKER_ARG_PHP_IMAGE_VERSION="PHP_IMAGE_TAG_VERSION=$(echo "$FULL_PHP_VERSION" | cut -d. -f1,2)" #
PHP_IMAGE_VERSION=$(echo "$FULL_PHP_VERSION" | cut -d. -f1,2)

echo "${YELLOW}Full version of php : v${FULL_PHP_VERSION} ${YELLOW}"
echo "${YELLOW}Tag version of php image : php:${PHP_IMAGE_VERSION}-apache ${YELLOW}"

echo "${GREEN}Build commande : #docker build --build-arg ${DOCKER_ARG_FULL_PHP_VERSION} --build-arg ${DOCKER_ARG_PHP_IMAGE_VERSION} . ${GREEN}"

set -x
docker build --build-arg "${DOCKER_ARG_FULL_PHP_VERSION}" --build-arg "${DOCKER_ARG_PHP_IMAGE_VERSION}" .
