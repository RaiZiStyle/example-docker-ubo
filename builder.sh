#!/bin/bash

# Color options :
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)

SHORT=p:s:c::h
LONG=php-full-version:symfony-version:no-cache::help
OPTS=$(getopt -a -n builder.sh --options $SHORT --longoptions $LONG -- "$@")
if [ $? -ne 0 ]; then
  # L'appel à getopt a échoué, cela signifie que des options non valides ont été fournies
  exit 1
fi


eval set -- "$OPTS"


usage() {
  printf "Usage of builder.sh : ./builder -p FULL_VERSION_PHP -s SYMFONY_VERSION\n"
  printf "Usage of builder.sh : ./builder --php-full-version=FULL_VERSION_PHP --symfony-version=SYMFONY_VERSION\n"
  printf "\tExample : ./builder.sh -p 8.1.19 -s 6.2  # Will build for php version 8.1.19 and symfony version 6.2\n"
  printf "\tExample : ./builder.sh --php-full-version=8.2.1 --symfony-version=6.3 # Will build for php version 8.2.1 and symfony version 6.3\n"
  exit 1

}

CACHE=""

while :; do
  case "$1" in
  -p | --php-full-version)
    FULL_PHP_VERSION="$2"
    shift 2
    ;;
  -c | --no-cache)
    CACHE="--no-cache"
    shift 2
    ;;
  -s | --symfony-version)
    SYMFONY_VERSION="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  --)
    # usage
    break
    ;;
  *)
    echo "Unexpected option: $1"
    exit 1
    ;;
  esac
done


# TODO: Check if arguments are well parsed
# Vérifier si les options obligatoires sont fournies
if [ -z "$FULL_PHP_VERSION" ] || [ -z "$SYMFONY_VERSION" ]; then
  echo "Les options -p et -s sont obligatoires."
  usage
fi


# Docker arguments
DOCKER_ARG_FULL_PHP_VERSION="FULL_PHP_VERSION=${FULL_PHP_VERSION}"                               # Result
DOCKER_ARG_PHP_IMAGE_VERSION="PHP_IMAGE_TAG_VERSION=$(echo "$FULL_PHP_VERSION" | cut -d. -f1,2)" #
DOCKER_ARG_SYMFONY_VERSION="SYMFONY_VERSION=${SYMFONY_VERSION}"

PHP_IMAGE_VERSION=$(echo "$FULL_PHP_VERSION" | cut -d. -f1,2)

echo "${YELLOW}Full version of php : v${FULL_PHP_VERSION} ${YELLOW}"
echo "${YELLOW}Tag version of php image : php:${PHP_IMAGE_VERSION}-apache ${YELLOW}"
echo "${YELLOW}Symfony version : v${SYMFONY_VERSION}-apache ${YELLOW}"

if [ ${CACHE} ]; then
  echo "${YELLOW}No Cache option is ON ${YELLOW}"
fi

sleep 1

echo "${GREEN}Build commande : #docker build --target DEBIAN_BUILD ${CACHE} -t php-symfony-apache:${FULL_PHP_VERSION} --build-arg ${DOCKER_ARG_FULL_PHP_VERSION} --build-arg ${DOCKER_ARG_PHP_IMAGE_VERSION} --build-arg ${DOCKER_ARG_SYMFONY_VERSION} . ${GREEN}"

set -x
docker build --target DEBIAN_BUILD ${CACHE} -t php-symfony-apache:"${FULL_PHP_VERSION}" --build-arg "${DOCKER_ARG_FULL_PHP_VERSION}" --build-arg "${DOCKER_ARG_PHP_IMAGE_VERSION}" --build-arg "${DOCKER_ARG_SYMFONY_VERSION}" .
