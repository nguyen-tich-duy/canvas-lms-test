#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

BASE_PATH=$(dirname $(realpath $0))
cd $BASE_PATH

source ./.env.production
source ./.env

if [ -z "$1" ]; then
    SERVICE_NAME=web
else
    SERVICE_NAME=$1
fi

docker exec -ti ${COMPOSE_PROJECT_NAME}_${SERVICE_NAME} env TERM=xterm ${CONTAINER_SHELL} ${CONTAINER_SHELL_ARGS[@]}
