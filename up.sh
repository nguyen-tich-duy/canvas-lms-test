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

source ./scripts/common.sh

[ "$1" == "--no-logs" ] && { NOLOG=1;shift; }

message "Update git repo"
exec_command "git submodule update --init --depth 1 canvas-lms"

message "Copy new settings"
exec_command "cp -r config/canvas-lms/* canvas-lms/config"

export DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')

[ "$ENABLE_HTTPS" == "false" ] && export HTTP_PROTOCOL_OVERRIDE=http

exec_command "docker-compose up -d  $@"

if [ "$NOLOG" != "1" ]; then
    bash ./logs.sh
fi
