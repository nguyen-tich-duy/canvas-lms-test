#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)


CMD_PATH=$(dirname $(realpath $0))

source $CMD_PATH/../scripts/common.sh

source $CMD_PATH/../.env.production
source $CMD_PATH/../.env

if [ -e /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf ]; then
  message \
"Nginx site config '${COMPOSE_PROJECT_NAME}.conf' exists at '/etc/nginx/sites-available'.
Do you want to sync it back? This will override current 'site.conf'."
  confirm_command "cp $CMD_PATH/conf/site.conf $CMD_PATH/conf/site.conf.bak \\
  && cp /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf $CMD_PATH/conf/site.conf" || true
else
  message "Nginx site config '${COMPOSE_PROJECT_NAME}.conf' does not exist at '/etc/nginx/sites-available'.
  Nothing to sync."
fi
