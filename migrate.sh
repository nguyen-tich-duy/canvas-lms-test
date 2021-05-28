#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

source ./.env.production
source ./.env

source ./scripts/common.sh

message "Update git repo"
exec_command "git submodule update --init --depth 1 canvas-lms"

message "Copy new settings"
exec_command "cp -r config/canvas-lms/* canvas-lms/config"

docker-compose run --rm web bundle exec rake db:migrate
