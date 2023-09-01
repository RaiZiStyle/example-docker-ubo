# How to build the image : 

```
docker build -t php-symfony-apache:8.1.19 --build-arg FULL_PHP_VERSION=8.1.19  --build-arg PHP_IMAGE_VERSION=8.1 . # Build for php version 8.2.1
docker build  -t php-symfony-apache:8.1.19 --build-arg PHP_BUILD_VERSION=8.1.19 . --no-cache # Build for php version 8.1.19
```


# Todo : 

- [ ] Make `FROM php-xx` to use the var parsed