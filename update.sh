#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

source ./.env.production
source ./.env

bash ./down.sh

docker pull ${WEB_IMAGE}
docker pull ${POSTGRES_IMAGE}

bash ./up.sh
