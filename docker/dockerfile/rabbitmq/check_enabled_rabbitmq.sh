#!/bin/bash


if [ "$ENABLE_RABBITMQ" = "false" ] || [ -z "$ENABLE_RABBITMQ" ]; 
then
    echo "Variable ENABLE_RABBITMQ is not set." ;
    echo "Exit" ;
    exit 1
else
    echo "Starting ENABLE_RABBITMQ with docker-entrypoint.sh" ;
    exec "$@" # Use to exec other entrypoint.
fi