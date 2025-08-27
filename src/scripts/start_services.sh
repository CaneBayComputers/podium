#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd "$(dirname "$(realpath "$0")")"

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

echo; echo


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

echo-green "Services are running!"; echo-white

cd "$ORIG_DIR"