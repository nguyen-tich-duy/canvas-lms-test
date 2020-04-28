#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

BASE_PATH=$(dirname $(realpath $0))
cd $BASE_PATH

source ./scripts/common.sh
source ./.env.production
source ./.env

message "Update git repo"
exec_command "git submodule update --init --depth 1"

message "Copy new settings"
exec_command "cp -r config/canvas-lms/* canvas-lms/config"

exec_command "docker-compose up -d  $@"

if [ "$NOLOG" != "1" ]; then
    bash ./logs.sh
fi
