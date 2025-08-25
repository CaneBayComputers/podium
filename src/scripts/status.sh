#!/bin/bash

set -e


cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh


# Variables
PROJECT_NAME=""

if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi

RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

# Docker handles port mapping automatically

HOSTS=$(cat /etc/hosts)


# Functions
project_status() {

  PROJ_NAME=$1


  echo -n PROJECT:

  echo-yellow " $PROJ_NAME"


  echo-white -n PROJECT FOLDER:

  if ! [ -d "$PROJ_NAME" ]; then

    echo-red " NOT FOUND"

    echo-white -n SUGGESTION:; echo-yellow " Check spelling or clone repo"

    return 1

  else

    echo-green " FOUND"

  fi


  echo-white -n HOST ENTRY: 

  if ! HOST_ENTRY=$(printf "%s\n" "$HOSTS" | grep " $PROJ_NAME$"); then

    echo-red " NOT FOUND"

    echo-white -n SUGGESTION:; echo-yellow " Run: setup_project.sh $PROJ_NAME"

    return 1

  else

    echo-green " FOUND"

  fi


  echo-white -n DOCKER STATUS:

  if ! [ "$(docker ps -q -f name=$PROJ_NAME)" ]; then

    echo-red " NOT RUNNING"

    echo-white -n SUGGESTION:; echo-yellow " Run startup.sh script"

    return 1

  else

    echo-green " RUNNING"

  fi


  echo-white -n DOCKER PORT MAPPING:

  EXT_PORT=$(echo $HOST_ENTRY | cut -d'.' -f 4 | cut -d' ' -f 1)

  # Check if Docker container has port mapping
  if ! docker port "$PROJ_NAME" 80/tcp > /dev/null 2>&1; then

    echo-red " NOT MAPPED"

    echo-white -n SUGGESTION:; echo-yellow " Run shutdown.sh then startup.sh script"

    return 1

  else

    echo-green " MAPPED"

  fi

  echo-white -n LOCAL ACCESS:; echo-yellow " http://$PROJ_NAME"

  echo-white -n LAN ACCESS:; echo-yellow " http://$LAN_IP:$EXT_PORT"
}


# Main

# Do not run as root
if [[ "$(whoami)" == "root" ]]; then

  echo-red "Do NOT run with sudo!"; echo-white; echo

  exit 1

fi


# Check if this environment is installed
if ! [ -f is_installed ]; then

  echo; echo-red 'Development environment has not been installed!'; echo-white

  echo 'Run install.sh'

  exit 1

fi


# Start CBC stack
if ! check-mariadb; then

  echo; echo-red 'Development environment is not started!'; echo-white

  echo 'Run startup.sh'

  exit 1

fi


# Iterate through projects folder
cd projects

if ! [ -z "$PROJECT_NAME" ]; then

  if project_status $PROJECT_NAME; then true; fi

  divider

else

  for PROJECT_NAME in *; do

    if project_status $PROJECT_NAME; then true; fi

    divider

  done

fi

cd ..

read -n 1 -r -s -p $'Press enter to continue...\n'

echo; echo

