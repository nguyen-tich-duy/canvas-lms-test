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

docker-compose run --rm $@
