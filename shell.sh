#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -u: Treat  unset  variables and parameters as an error when performing parameter expansion.
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

source ./.env

docker exec -ti ${COMPOSE_PROJECT_NAME}_web env TERM=xterm ${CONTAINER_SHELL} ${CONTAINER_SHELL_ARGS[@]}
