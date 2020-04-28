#!/bin/bash

set -eo pipefail

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked

BASE_PATH=$(dirname $(realpath $0))
WEB_ROOT=$BASE_PATH/canvas-lms

cd $BASE_PATH

source ./scripts/common.sh
source ./.env.build
source ./.env

message "Update git repo"
git submodule update --init --depth 1

# build canvas-lms
message "Building canvas-lms"

# patches

source patches/default_font.sh
source patches/footer.sh

# .env
cat >canvas-lms/.env<<EOF
COMPOSE_PROJECT_NAME=${BUILD_PREFIX}-lms
WEB_IMAGE=${WEB_IMAGE}
POSTGRES_IMAGE=${POSTGRES_IMAGE}
EOF

# config
cp -r docker-compose/canvas-lms/* canvas-lms/
cp -r config/canvas-lms/* canvas-lms/config/

cd $WEB_ROOT

if [ "$1" == "clean" ]; then
    docker-compose down --rmi local
else
    docker-compose build
fi
cd ..

# build canvas-rce-api
message "Building canvas-rce-api"

cat >canvas-rce-api/.env<<EOF
COMPOSE_PROJECT_NAME=${BUILD_PREFIX}-rce-api
RCE_IMAGE=${RCE_IMAGE}
EOF

cp -r docker-compose/canvas-rce-api/* canvas-rce-api/

cd $BASE_PATH/canvas-rce-api

if [ "$1" == "clean" ]; then
    docker-compose down --rmi local
else
    docker-compose build
fi
cd ..