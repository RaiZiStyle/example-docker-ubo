FROM debian:12-slim
# Nom du mainteneur
LABEL maintainer="arthur.guyotpremel@gmail.com"

ARG FULL_PHP_VERSION=-1
ARG PHP_IMAGE_VERSION

RUN if [ "$FULL_PHP_VERSION" = -1 ]; then echo "Set PHP_BUILD_VERSION in docker build-args like --build-arg FULL_PHP_VERSION=<Major.Minor.bugFix>" && exit 2; \
    else echo "FULL_PHP_VERSION is set"; \
    fi

RUN if [ "$PHP_IMAGE_VERSION" = -1 ]; then echo "Set PHP_IMAGE_VERSION in docker build-args like --build-arg PHP_IMAGE_VERSION=<Major.Minor>" && exit 2; \
    else echo "PHP_IMAGE_VERSION is set"; \
    fi


RUN  echo  "FULL php version is : $FULL_PHP_VERSION"



# Doesn work because : 
# Each RUN statement in a Dockerfile is run in a separate shell. So once a statement is done, all environment variables are lost. Even if they are exported.
# So we can't parse FULL_PHP_VERSION to get only Major.Minor
# RUN PHP_VERSION_DOCKER=$(echo "$PHP_BUILD_VERSION" | cut -d. -f1,2) && \
#     export PHP_VERSION_DOCKER && \
#     echo "Exported PHP_VERSION_DOCKER variable with value : $PHP_VERSION_DOCKER"

# RUN set -eux PHP_VERSION_DOCKER=$(echo "$PHP_BUILD_VERSION")
# RUN PHP_VERSION_DOCKER=$(echo $PHP_BUILD_VERSION | cut -d. -f1,2) && \
#     echo "php version for tag is : $PHP_VERSION_DOCKER"
# ENV PHP_VERSION_DOCKER=$(echo "$PHP_BUILD_VERSION")

RUN echo "php version for tag is : $PHP_IMAGE_VERSION"
# RUN echo "$PHP_VERSION_DOCKER"
ARG PHP_IMAGE_VERSION
FROM php:${PHP_IMAGE_VERSION}-apache
# FROM php:8.1-apache
RUN apt update -y
# RUN apt install 
# Pass l'argument $PHP_BUILD_VERSION en variable d'environnement dans le conteuneur
ENV PHP_VERSION=${FULL_PHP_VERSION} 
