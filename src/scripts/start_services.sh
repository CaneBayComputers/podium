#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd "$(dirname "$(realpath "$0")")"

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

echo-return; echo-return


# Main
source "$DEV_DIR/scripts/pre_check.sh"


# Start CBC stack
if ! check-mariadb; then

  echo-cyan "Starting services ..."; echo-white

  cd docker-stack

  dockerup

  cd ..

  sleep 5

fi

# JSON output for service start
if [[ "$JSON_OUTPUT" == "1" && "$SUPPRESS_INTERMEDIATE_JSON" != "1" ]]; then
    echo "{\"action\": \"start_services\", \"status\": \"success\"}"
elif [[ "$JSON_OUTPUT" != "1" ]]; then
    echo-green "Services are running!"; echo-white
fi

cd "$ORIG_DIR"