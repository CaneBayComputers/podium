#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases

echo; echo


# Main
cd scripts

source pre_check.sh

cd ..


# Start CBC stack
if ! check-mariadb; then

  echo; echo-cyan "Starting services ..."; echo-white; echo

  cd docker-stack

  dockerup

  cd ..

  sleep 5

fi

echo-green "Services are running!"; echo-white; echo

cd $ORIG_DIR