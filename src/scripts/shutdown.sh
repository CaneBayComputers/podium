#!/bin/bash

set -e


cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

echo; echo


# Variables
if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi


# Functions
# Docker handles all networking - no iptables rules needed

shutdown_container() {

	CONTAINER_NAME=$1

	REPO_DIR=projects/$CONTAINER_NAME;

  if [ -d "$REPO_DIR" ]; then

  	if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then

	  	echo; echo-cyan "Shutting down $CONTAINER_NAME ..."; echo-white; echo

	  	cd $REPO_DIR

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
echo; echo-green "Docker containers shut down successfully!"; echo-white; echo


# Shut down Docker containers
if [ -z "$PROJECT_NAME" ]; then

	for CONTAINER_ID in $(docker ps -q); do

	    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' $CONTAINER_ID | sed 's/^\/\+//')

	    shutdown_container $CONTAINER_NAME;

	done

	if check-mariadb; then

		echo; echo-cyan "Shutting down services ..."; echo-white; echo

		cd docker-stack

	  dockerdown

	  echo-green "Successfully shut down services!"; echo-white; echo

	  cd ..

	fi

else

	shutdown_container $PROJECT_NAME

fi

