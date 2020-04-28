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
"There is already a '${COMPOSE_PROJECT_NAME}.conf' at '/etc/nginx/sites-available'.
Do you want to override that file?"
  confirm_command "sudo cp $CMD_PATH/conf/site.conf /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf" || true
else
  exec_command "sudo cp $CMD_PATH/conf/site.conf /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf"
fi


if [ ! -e /etc/nginx/sites-enabled/${COMPOSE_PROJECT_NAME}.conf ]; then
    message "Enable site ${COMPOSE_PROJECT_NAME}.conf"
    exec_command "sudo ln -s /etc/nginx/sites-available/${COMPOSE_PROJECT_NAME}.conf /etc/nginx/sites-enabled/${COMPOSE_PROJECT_NAME}.conf"
fi

message "Reload nginx..."
exec_command "sudo nginx -s reload"

# sudo tail -f /var/log/nginx/${COMPOSE_PROJECT_NAME}_access.log
