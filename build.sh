#!/bin/bash

set -eo pipefail

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked

function usage {
  echo "./build.sh          : build local only"
  echo "./build.sh clean    : remove all images"
  echo "./build.sh push     : build and push"
  echo "./build.sh push-only: push only (no build)"
}

BASE_PATH=$(dirname $(realpath $0))
WEB_ROOT=$BASE_PATH/canvas-lms

cd $BASE_PATH

source ./scripts/common.sh
source ./.env.build
source ./.env

unset SKIP_BUILD ACTION

case "$1" in
  push|clean)
    ACTION=$1
    shift;;
  "push-only")
    ACTION=push
    SKIP_BUILD=1
    shift;;
  -h|--help)
    usage
    exit 2;;
esac

message "Update git repo"
git submodule update --init --depth 1

message "Add Analytics module"
#rm -rf $WEB_ROOT/gems/plugins/analytics
[ ! -e $WEB_ROOT/gems/plugins/analytics ] && git clone https://github.com/instructure/analytics $WEB_ROOT/gems/plugins/analytics --depth 1

message "Add QTI module"
mkdir -p $WEB_ROOT/vendor
[ ! -e $WEB_ROOT/vendor/QTIMigrationTool ] && git clone https://github.com/instructure/QTIMigrationTool.git $WEB_ROOT/vendor/QTIMigrationTool --depth 1

# build canvas-lms
message "Building canvas-lms"

# .env
cat >canvas-lms/.env<<EOF
COMPOSE_PROJECT_NAME=${BUILD_PREFIX}-lms
WEB_IMAGE=${WEB_IMAGE}
POSTGRES_IMAGE=${POSTGRES_IMAGE}
EOF

# config
cp -ur docker-compose/canvas-lms/* canvas-lms/
cp -ur config/canvas-lms/* canvas-lms/config/

cd $WEB_ROOT

if [ "$ACTION" == "clean" ]; then
  docker-compose down --rmi local
else
  [ -z "$SKIP_BUILD" ] && docker-compose build || message "[SKIPPED]"
fi
cd ..

# build canvas-rce-api
message "Building canvas-rce-api"

cat >canvas-rce-api/.env<<EOF
COMPOSE_PROJECT_NAME=${BUILD_PREFIX}-rce-api
RCE_IMAGE=${RCE_IMAGE}
EOF

cp -ur docker-compose/canvas-rce-api/* canvas-rce-api/

cd $BASE_PATH/canvas-rce-api

if [ "$ACTION" == "clean" ]; then
  docker-compose down --rmi local
else
  [ -z "$SKIP_BUILD" ] && docker-compose build || message "[SKIPPED]"
fi
cd ..

if [ "$ACTION" == "push" ]; then
  cd $WEB_ROOT
  # ignore docker-compose.override.yml to avoid mistake
  exec_command "docker-compose push"

  cd $BASE_PATH/canvas-rce-api
  # ignore docker-compose.override.yml to avoid mistake
  exec_command "docker-compose push"
fi
