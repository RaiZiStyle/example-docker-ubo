#!/bin/bash


if [ "$ENABLE_MYSQL" = "false" ] || [ -z "$ENABLE_MYSQL" ]; 
then
    echo "Variable ENABLE_MYSQL is not set." ;
    echo "Exit" ;
    exit 1
else
    echo "Starting Mysql with docker-entrypoint.sh" ;
    exec "$@" # Use to exec other entrypoint.
fi