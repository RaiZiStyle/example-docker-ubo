# Needed before the from in order to be used by the `FROM`
ARG FULL_PHP_VERSION
ARG PHP_IMAGE_TAG_VERSION

# Used to test if variable is set via --build-arg
# Can't run `RUN` without a from.
FROM debian:12-slim
# Nom du mainteneur
LABEL maintainer="arthur.guyotpremel@gmail.com"


# Check if full version of php is set
RUN if [ "$FULL_PHP_VERSION" = -1 ]; then echo "Set PHP_BUILD_VERSION in docker build-args like --build-arg FULL_PHP_VERSION=<Major.Minor.bugFix>" && exit 2; \
    else echo "FULL_PHP_VERSION is set"; \
    fi

# Check if image version of php is set
RUN if [ "$PHP_IMAGE_TAG_VERSION" = -1 ]; then echo "Set PHP_IMAGE_TAG_VERSION in docker build-args like --build-arg PHP_IMAGE_TAG_VERSION=<Major.Minor>" && exit 2; \
    else echo "PHP_IMAGE_TAG_VERSION is set"; \
    fi


RUN  echo  "FULL php version is : $FULL_PHP_VERSION"


RUN echo "php version for tag is : $PHP_IMAGE_TAG_VERSION"

FROM php:${PHP_IMAGE_TAG_VERSION}-apache

RUN apt update -y

# Use to have a environement variable name `PHP_VERSION` in the container
ENV PHP_VERSION=${FULL_PHP_VERSION} 
