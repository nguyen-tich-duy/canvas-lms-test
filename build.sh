#!/bin/bash

set -eo pipefail

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked

BASE_PATH=$(dirname $(realpath $0))

cd $BASE_PATH

source ./.env.production
source ./.env

git submodule update --init --depth 1

cp .env canvas-lms/
cp .env.* canvas-lms/

cp -r docker-compose/canvas-lms/* canvas-lms/
cp -r config/canvas-lms/* canvas-lms/config/

cd $BASE_PATH/canvas-lms

if [ "$1" == "clean" ]; then
    docker-compose down --rmi local
else
    docker-compose build
fi
