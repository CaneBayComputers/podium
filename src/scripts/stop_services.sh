#!/bin/bash

set -e

ORIG_DIR=$(pwd)

cd "$(dirname "$(realpath "$0")")"

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

echo-return; echo-return

# Main
# Stop CBC stack services
if check-mariadb; then

  echo-cyan "Stopping services ..."; echo-white

  cd docker-stack

  dockerdown

  cd ..

  sleep 2

else

  echo-yellow "Services are already stopped."; echo-white

fi

# JSON output for service stop
if [[ "$JSON_OUTPUT" == "1" ]]; then
    echo "{\"action\": \"stop_services\", \"status\": \"success\"}"
else
    echo-green "Services stopped!"; echo-white
fi

cd "$ORIG_DIR"
