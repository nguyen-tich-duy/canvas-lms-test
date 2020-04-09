#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

source ./.env

# Create user and group on Host for container.
CONTAINER_UID=9999
CONTAINER_GID=9999
CONTAINER_USER=user
CONTAINER_GROUP=user

# Ubuntu
getent group $CONTAINER_GROUP &>/dev/null              ||  \
    sudo groupadd -g $CONTAINER_GID $CONTAINER_GROUP

id -u $CONTAINER_USER  &>/dev/null              ||  \
    sudo useradd -u $CONTAINER_UID                  \
        -g $CONTAINER_GROUP                         \
        -d /home/$CONTAINER_USER                    \
        -s /bin/false                               \
        $CONTAINER_USER                      

sudo mkdir -p $DATA_PATH

sudo chown -R $CONTAINER_USER:$CONTAINER_GROUP $DATA_PATH

docker network inspect $NETWORK_NAME || docker network create $NETWORK_NAME

docker-compose up -d $@

# bash ./nginx-update.sh

if [ "$NOLOG" != "1" ]; then
    bash ./logs.sh
fi
