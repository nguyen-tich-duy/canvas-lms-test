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

source scripts/common.sh

message "Update git repo"
exec_command "git submodule update --init --depth 1 canvas-lms"

message "Copy new settings"
exec_command "cp -r config/canvas-lms/* canvas-lms/config"

export DOCKER_HOST_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')

function database_exists {
  docker-compose run --rm web \
    bundle exec rails runner 'ActiveRecord::Base.connection' &> /dev/null
}

function create_db {
  if ! docker-compose run --no-deps --rm web touch db/structure.sql; then
    message \
"The 'docker' user is not allowed to write to db/structure.sql. We need write
permissions so we can run migrations."
    touch db/structure.sql
    confirm_command 'chmod a+rw db/structure.sql' || true
  fi

  if database_exists; then
    message \
'An existing database was found.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
This script will destroy ALL EXISTING DATA if it continues
If you want to migrate the existing database, use migrate.sh
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    message 'About to run "bundle exec rake db:drop"'
    prompt "type NUKE in all caps: " nuked
    [[ ${nuked:-n} == 'NUKE' ]] || exit 1
    docker-compose run -e DISABLE_DATABASE_ENVIRONMENT_CHECK=$DISABLE_DATABASE_ENVIRONMENT_CHECK --rm web \
      bundle exec rake db:drop
  fi

  message "Creating new database"
  docker-compose run --rm web \
    bundle exec rake db:create
  docker-compose run -e CANVAS_LMS_STATS_COLLECTION=$CANVAS_LMS_STATS_COLLECTION --rm web \
    bundle exec rake db:initial_setup
}

create_db
