#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)


BASE_PATH=$(dirname $(dirname $(realpath $0)))

cd $BASE_PATH

source ./scripts/common.sh

source ./.env.production
source ./.env

export COMPOSE_FILE=docker-compose.yml:docker-compose.pgadmin.yml

exec_command "docker-compose exec pgadmin sh -l"
