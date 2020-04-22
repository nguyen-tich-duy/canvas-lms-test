#!/bin/bash

set -eo pipefail

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked

BASE_PATH=$(dirname $(realpath $0))

pushd $BASE_PATH

source ./.env

cp .env canvas-lms/
cp .env.* canvas-lms/

cp -r docker-compose/canvas-lms/* canvas-lms/
cp -r config/canvas-lms/* canvas-lms/config/

pushd $BASE_PATH/canvas-lms

docker-compose build
# bash ./build/canvas-lms/build.sh

popd
popd