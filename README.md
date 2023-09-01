# How to build the image : 

```
docker build -t php-symfony-apache:8.1.19 --build-arg FULL_PHP_VERSION=8.1.19  --build-arg PHP_IMAGE_VERSION=8.1 . # Build for php version 8.2.1
docker build  -t php-symfony-apache:8.1.19 --build-arg PHP_BUILD_VERSION=8.1.19 . --no-cache # Build for php version 8.1.19
```


# Todo : 

- [x] Create dynamic env variable
  - Use via `ENV PHP_VERSION=${FULL_PHP_VERSION}` and $FULL_PHP_VERSION is given as a docker build arg (--build-arg FULL_PHP_VERSION=8.1.19)    
- [ ] Make `FROM php-xx` to use the var parsed

# Improuvements : 

Might be better to use a `Makefile` or a `.sh` to build the `Dockerfile` since we can't parse variable in the `Dockerfile`
Somethink like `./builder FULL_PHP_VERSION=8.1.19`   
And the script will do somethink like :    
```sh
# Vérifier si le premier argument est vide
if [ -z "$1" ]; then
    echo "usage : ./builder FULL_PHP_VERSION=8.1.19" 
    exit 1
fi
#FULL_PHP_VERSION=8.1.19
DOCKER_ARG_PHP_IMAGE_VERSION="PHP_IMAGE_TAG_VERSION=$(echo "$PHP_BUILD_VERSION" | cut -d. -f1,2)" # Result in DOCKER_ARG_PHP_IMAGE_VERSION=PHP_IMAGE_TAG_VERSION=8.1
DOCKER_ARG_FULL_PHP_VERSION="FULL_PHP_VERSION=$(echo "$PHP_BUILD_VERSION" | cut -d. -f1,2)" # Result in DOCKER_ARG_FULL_PHP_VERSION=FULL_PHP_VERSION=8.1.19

docker build --build-arg ${DOCKER_ARG_PHP_IMAGE_VERSION} --build-arg ${DOCKER_ARG_FULL_PHP_VERSION}
# Will result in : 
docker build --build-arg PHP_IMAGE_TAG_VERSION=8.1 --build-arg FULL_PHP_VERSION=8.1.19
```
> This script can be usefull because we can't parse Variable in a Dockerfile, so the script is used to only give 1 arguments (AKA FULL_PHP_VERSION)   
> The script will parse the FULL_PHP_VERSION and exctract <PHP_IMAGE_TAG_VERSION> used for the FROM php-${PHP_IMAGE_TAG_VERSION}   


# Issues : 
Not possible to parse variable in the dockerfile.    
I wanted to only give one variable with `--build-arg FULL_BUILD_VERSION=8.1.19`, and do :    
```Dockerfile
RUN PHP_IMAGE_VERSION=$(echo "$PHP_BUILD_VERSION" | cut -d. -f1,2) && \
    export PHP_IMAGE_VERSION && \
    echo "Exported PHP_IMAGE_VERSION variable with value : $PHP_IMAGE_VERSION" # So that PHP_IMAGE_VERSION=8.1
# To use like so : 
FROM php:${PHP_IMAGE_VERSION}
```
But it doesn work because :    
Each RUN statement in a Dockerfile is run in a separate shell. So once a statement is done, all environment variables are lost. Even if they are exported.   
So we can't parse FULL_PHP_VERSION to get only Major.Minor   