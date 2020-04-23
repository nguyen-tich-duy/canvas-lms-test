#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

source ./.env.production
source ./.env

sudo cp nginx/site.conf /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf
if [ ! -e /etc/nginx/sites-enabled/${COMPOSE_PROJECT_NAME}.conf ]; then
    sudo ln -s /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf /etc/nginx/sites-enabled/${COMPOSE_PROJECT_NAME}.conf
fi
sudo nginx -s reload

# sudo tail -f /var/log/nginx/${COMPOSE_PROJECT_NAME}_access.log
