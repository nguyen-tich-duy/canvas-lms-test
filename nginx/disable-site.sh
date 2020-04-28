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

if [ -e /etc/nginx/sites-enabled/${COMPOSE_PROJECT_NAME}.conf ]; then
    message "Disable site ${COMPOSE_PROJECT_NAME}.conf"
    exec_command "sudo rm /etc/nginx/sites-enabled/${COMPOSE_PROJECT_NAME}.conf"
fi

message "Reload nginx..."
exec_command "sudo nginx -s reload"

# sudo tail -f /var/log/nginx/${COMPOSE_PROJECT_NAME}_access.log
