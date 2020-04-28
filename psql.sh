#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -u: Treat  unset  variables and parameters as an error when performing parameter expansion.
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

BASE_PATH=$(dirname $(realpath $0))
cd $BASE_PATH

source ./.env.production
source ./.env

# make sure the container is started
docker-compose start postgres

function less_exists {
  docker-compose exec postgres less -V &> /dev/null
}

if ! less_exists; then
  echo "Install support tools"
  docker-compose exec postgres apt-get update
  docker-compose exec postgres apt-get install less -y
  docker-compose exec postgres rm rm -rf /var/lib/apt/lists/*
fi

echo "Start psql..."
docker-compose exec postgres env LESS='-S' su postgres -c "psql canvas"
