#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

# Do not run as root
if [[ "$(whoami)" == "root" ]]; then

  echo-red "Do NOT run with sudo!"; echo-white; echo

  exit 1

fi


# Check if this environment is configured
if ! [ -f docker-stack/.env ]; then

  echo; echo-red 'Development environment has not been configured!'; echo-white

  echo 'Run: podium config'

  exit 0

fi

cd $ORIG_DIR