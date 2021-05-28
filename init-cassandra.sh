#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

# -e: immediately exit if any command has a non-zero exit status
# -o: prevents errors in a pipeline from being masked
# IFS new value is less likely to cause confusing bugs when looping arrays or arguments (e.g. $@)

BASE_PATH=$(dirname $(realpath $0))

cd $BASE_PATH

source ./.env.production
source ./.env

source scripts/common.sh

docker-compose start cassandra || docker-compose up -d cassandra

message "Wait for cassandra ready..."

wait_timeout=6
while { ! docker-compose exec cassandra cqlsh -u cassandra -p cassandra -e "SHOW HOST" > /dev/null; } && [ $wait_timeout -gt 0 ]; do
  echo $wait_timeout
  sleep 3
  wait_timeout=$((wait_timeout-1))
done

message "Create keyspace..."

docker-compose exec cassandra cqlsh -u cassandra -p cassandra --connect-timeout=15 --request-timeout=15 -e "\
CREATE KEYSPACE page_views WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
CREATE KEYSPACE auditors WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };" \
 \
  && message "Keyspace created"