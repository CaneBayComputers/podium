#!/bin/bash

set -e

shopt -s expand_aliases

cd ~/repos/cbc-development-setup

source .bash_aliases

for CONTAINER_ID in $(docker ps -q); do

    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' $CONTAINER_ID | sed 's/^\/\+//')

    REPO_DIR=~/repos/$CONTAINER_NAME;

    if [ -d "$REPO_DIR" ]; then

    	echo; echo-green "Shutting down $CONTAINER_NAME ..."; echo-white; echo

    	cd $REPO_DIR

    	dockerdown

    	divider

    fi

done