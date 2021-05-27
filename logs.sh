#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

# Usage:
#   Show canvas production.log
#     ./logs.sh production
#   Show docker logs for the related service
#     ./logs.sh postgres
#     ./logs.sh web
#   Show all docker logs
#     ./logs.sh

source ./.env.production
source ./.env

if [ "$1" == "production" ]; then
  sudo tail -n 100 -f /var/lib/docker/volumes/${COMPOSE_PROJECT_NAME}_log/_data/production.log | ccze -A
else
  docker-compose logs --tail=100 -f $@ | ccze -A
fi
