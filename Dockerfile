# Needed before the from in order to be used by the `FROM`
ARG FULL_PHP_VERSION=-1
ARG PHP_IMAGE_TAG_VERSION=-1
ARG SYMFONY_VERSION=-1

# Used to test if variable is set via --build-arg
# Can't run `RUN` without a from.
FROM debian:12-slim as DEBIAN_BUILD
# Nom du mainteneur
LABEL maintainer="arthur.guyotpremel@gmail.com"

# Check if full version of php is set
# FIXME: I don't understand why this doesn't work
RUN if [ "$FULL_PHP_VERSION" == "-1" ]; then echo "Set PHP_BUILD_VERSION in docker build-args like --build-arg FULL_PHP_VERSION=<Major.Minor.bugFix>" && exit 2; \
    else echo "FULL_PHP_VERSION is set"; \
    fi

# Check if image version of php is set
RUN if [ "$PHP_IMAGE_TAG_VERSION" == "-1" ]; then echo "Set PHP_IMAGE_TAG_VERSION in docker build-args like --build-arg PHP_IMAGE_TAG_VERSION=<Major.Minor>" && exit 2; \
    else echo "PHP_IMAGE_TAG_VERSION is set"; \
    fi

# Check if full version of php is set
RUN if [ "${SYMFONY_VERSION}" == "-1" ]; then echo "Set SYMFONY_VERSION in docker build-args like --build-arg SYMFONY_VERSION=<Major.Minor>" && exit 2; \
    else echo "SYMFONY_VERSION is set"; \
    fi

# FIXME: Doesn always show...
RUN  echo  "FULL php version is : $FULL_PHP_VERSION"
RUN echo "PHP version for tag is : $PHP_IMAGE_TAG_VERSION"
RUN echo "Symfony version for tag is : $SYMFONY_VERSION"

FROM php:${PHP_IMAGE_TAG_VERSION}-apache as PHP_APACHE_INSTALL

RUN apt update -y

# Use to have a environement variable name `PHP_VERSION` in the container
ENV PHP_VERSION=${FULL_PHP_VERSION} 



#### FROM https://github.com/systemsdk/docker-apache-php-symfony/blob/master/Dockerfile
#### AKA systemsdk/docker-apache-php-symfony
# set main params
ARG BUILD_ARGUMENT_ENV=dev
ENV ENV=$BUILD_ARGUMENT_ENV
ENV APP_HOME /var/www/html
ARG HOST_UID=1000
ARG HOST_GID=1000
ENV USERNAME=www-data
ARG INSIDE_DOCKER_CONTAINER=1
ENV INSIDE_DOCKER_CONTAINER=$INSIDE_DOCKER_CONTAINER
ARG XDEBUG_CONFIG=main
ENV XDEBUG_CONFIG=$XDEBUG_CONFIG

# install all the dependencies and enable PHP modules
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      procps \
      nano \
      git \
      unzip \
      libicu-dev \
      zlib1g-dev \
      libxml2 \
      libxml2-dev \
      libreadline-dev \
      cron \
      sudo \
      libzip-dev \
      wget \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
      pdo_mysql \
      sockets \
      intl \
      opcache \
      zip \
    && rm -rf /tmp/* \
    && rm -rf /var/list/apt/* \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


# disable default site and delete all default files inside APP_HOME
RUN a2dissite 000-default.conf
RUN rm -r $APP_HOME

# create document root, fix permissions for www-data user and change owner to www-data
RUN mkdir -p $APP_HOME/public && \
    mkdir -p /home/$USERNAME && chown $USERNAME:$USERNAME /home/$USERNAME \
    && usermod -o -u $HOST_UID $USERNAME -d /home/$USERNAME \
    && groupmod -o -g $HOST_GID $USERNAME \
    && chown -R ${USERNAME}:${USERNAME} $APP_HOME

# put apache and php config for Symfony, enable sites
COPY ./docker/general/symfony.conf /etc/apache2/sites-available/symfony.conf
COPY ./docker/general/symfony-ssl.conf /etc/apache2/sites-available/symfony-ssl.conf
RUN a2ensite symfony.conf && a2ensite symfony-ssl
COPY ./docker/$BUILD_ARGUMENT_ENV/php.ini /usr/local/etc/php/php.ini

# enable apache modules
RUN a2enmod rewrite
RUN a2enmod ssl

# install Xdebug in case dev/test environment
COPY ./docker/general/do_we_need_xdebug.sh /tmp/
COPY ./docker/dev/xdebug-${XDEBUG_CONFIG}.ini /tmp/xdebug.ini
RUN chmod u+x /tmp/do_we_need_xdebug.sh && /tmp/do_we_need_xdebug.sh

# install security-checker in case dev/test environment
COPY ./docker/general/do_we_need_security-checker.sh /tmp/
RUN chmod u+x /tmp/do_we_need_security-checker.sh && /tmp/do_we_need_security-checker.sh

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

# add supervisor
RUN mkdir -p /var/log/supervisor
COPY --chown=root:root ./docker/general/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=root:crontab ./docker/general/cron /var/spool/cron/crontabs/root
RUN chmod 0600 /var/spool/cron/crontabs/root

# generate certificates
# TODO: change it and make additional logic for production environment
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

# set working directory
WORKDIR $APP_HOME

USER ${USERNAME}

# Create an empty Symfony project
RUN composer create-project symfony/skeleton:"${SYMFONY_VERSION}" .
RUN composer require webapp


# copy source files
COPY --chown=${USERNAME}:${USERNAME} . $APP_HOME/

# install all PHP dependencies
# RUN if [ "$BUILD_ARGUMENT_ENV" = "dev" ] || [ "$BUILD_ARGUMENT_ENV" = "test" ]; then COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-interaction --no-progress; \
#     else export APP_ENV=$BUILD_ARGUMENT_ENV && COMPOSER_MEMORY_LIMIT=-1 composer install --optimize-autoloader --no-interaction --no-progress --no-dev; \
#     fi

# # create cached config file .env.local.php in case staging/prod environment
# RUN if [ "$BUILD_ARGUMENT_ENV" = "staging" ] || [ "$BUILD_ARGUMENT_ENV" = "prod" ]; then composer dump-env $BUILD_ARGUMENT_ENV; \
#     fi

# USER root
