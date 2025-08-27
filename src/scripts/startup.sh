#!/bin/bash

# In the Startup Applications manager enter this command to run this script to start up repos:
# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e


# Store the current directory (should be projects directory)
PROJECTS_DIR=$(pwd)

cd "$(dirname "$(realpath "$0")")"

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

# Env vars
source docker-stack/.env

# Return to projects directory for project operations
cd "$PROJECTS_DIR"


# Vars
NO_STATUS=false
PROJECT_NAME=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-status) NO_STATUS=true ;;
        *) PROJECT_NAME="$1" ;;
    esac
    shift
done


# Functions
start_project() {

  PROJECT_FOLDER_NAME=$1

  echo; echo-cyan "Starting up $PROJECT_FOLDER_NAME ..."; echo-white

  if ! [ -d "$PROJECT_FOLDER_NAME" ]; then

    echo-red 'Project folder not found!'; echo-white

    exit 1

  fi

  cd "$PROJECT_FOLDER_NAME"

  if ! [ -f docker-compose.yaml ]; then

    echo-red 'No docker-compose.yaml file found!'

    echo-white 'Possibly not installed. Skipping ...'

    cd ..

    return 1

  fi

  dockerup

  sleep 5

  cd ..

  echo-green "Project $PROJECT_FOLDER_NAME started successfully!"
}


# Main
source "$DEV_DIR/scripts/start_services.sh"

# Ensure we're back in the projects directory after sourcing other scripts
cd "$(get_projects_dir)"

# Start projects either just one by name or all in the projects directory
# Note: We're in the projects directory

if ! [ -z "$PROJECT_NAME" ]; then

  if start_project $PROJECT_NAME; then true; fi

else

  # Ensure we're in the projects directory before iterating
  cd "$(get_projects_dir)"
  
  for PROJECT_FOLDER_NAME in *; do

    if start_project $PROJECT_FOLDER_NAME; then true; fi

  done

fi


# Docker handles all networking automatically

if ! $NO_STATUS; then

  source "$DEV_DIR/scripts/status.sh" $PROJECT_NAME

elif [[ "$JSON_OUTPUT" == "1" ]]; then
  # For JSON output, we still need to call status.sh to get the data
  source "$DEV_DIR/scripts/status.sh" $PROJECT_NAME
fi