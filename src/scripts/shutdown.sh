#!/bin/bash

set -e

# Store current working directory (should be projects directory)
PROJECTS_DIR=$(pwd)

# Get the CLI directory for sourcing functions
CLI_DIR=$(dirname "$(realpath "$0")")
cd "$CLI_DIR/.."
DEV_DIR=$(pwd)

source scripts/functions.sh

# Return to projects directory
cd "$PROJECTS_DIR"

echo; echo


# Variables
if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi


# Functions
# Docker handles all networking - no iptables rules needed

shutdown_container() {

        CONTAINER_NAME=$1

        REPO_DIR=$CONTAINER_NAME;

  if [ -d "$REPO_DIR" ]; then

  	if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then

	  	echo; echo-cyan "Shutting down $CONTAINER_NAME ..."; echo-white; echo

	  	cd "$REPO_DIR"

	  	dockerdown

	  	echo-green "Successfully shut down $CONTAINER_NAME!"; echo-white; echo

	  	cd ../..

	  else

	  	echo; echo-yellow "Container $CONTAINER_NAME is not running!"; echo-white; echo

	  fi

  	divider

  fi
}


#######################################################
# Main
#######################################################


# Define the comment to search for
CUSTOM_COMMENT="cbc-rule"

if [ -n "$PROJECT_NAME" ]; then

	CUSTOM_COMMENT="${CUSTOM_COMMENT}-${PROJECT_NAME}"

fi


# Docker handles all networking automatically - no iptables cleanup needed

# Shut down Docker containers
if [ -z "$PROJECT_NAME" ]; then

	for CONTAINER_ID in $(docker ps -q); do

	    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' $CONTAINER_ID | sed 's/^\/\+//')

	    shutdown_container $CONTAINER_NAME;

	done

	        if check-mariadb; then

                echo; echo-cyan "Shutting down services ..."; echo-white; echo

                cd "$DEV_DIR/docker-stack"

          dockerdown

          echo-green "Successfully shut down services!"; echo-white; echo

          cd "$PROJECTS_DIR"

        fi

else

        shutdown_container $PROJECT_NAME

fi

echo; echo-green "Docker containers shut down successfully!"; echo-white; echo

