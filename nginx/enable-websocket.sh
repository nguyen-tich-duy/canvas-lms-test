#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

CMD_PATH=$(dirname $(realpath $0))

source $CMD_PATH/../scripts/common.sh

if [ -e /etc/nginx/sites-available/websocket.conf ]; then
  message \
"There is already a 'websocket.conf' at '/etc/nginx/sites-available'.
Do you want to override that file?"
  confirm_command "sudo cp $CMD_PATH/conf/websocket.conf /etc/nginx/sites-available/websocket.conf" || true
else
  message "Copy websocket.conf to /etc/nginx/sites-available/"
  exec_command "sudo cp $CMD_PATH/conf/websocket.conf /etc/nginx/sites-available/websocket.conf"
fi

if [ ! -e /etc/nginx/sites-enabled/websocket.conf ]; then
    message "Enable site websocket.conf"
    exec_command "sudo ln -s /etc/nginx/sites-available/websocket.conf /etc/nginx/sites-enabled/websocket.conf"
fi

message "Reload nginx..."
exec_command "sudo nginx -s reload"
