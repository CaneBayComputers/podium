#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases

echo; echo


# Variables
if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi


# Functions
remove_custom_rules() {

	table=$1

	chain=$2

	comment=$3

	# List the rules with line numbers, search for the comment, extract line numbers, and remove those rules
	iptables -t $table -L $chain --line-numbers -n | grep "$comment" | awk '{print $1}' | tac | while read -r line_number; do
		
		iptables -t $table -D $chain $line_number
	
	done
}


#######################################################
# Main
#######################################################


# Define the comment to search for
CUSTOM_COMMENT="cbc-rule"

if ! [ -z "$PROJECT_NAME" ]; then

	$CUSTOM_COMMENT+=""

fi


# Remove custom rules from the filter table
for chain in INPUT FORWARD OUTPUT; do
	
	remove_custom_rules filter $chain $CUSTOM_COMMENT
	
done


# Remove custom rules from the nat table
for chain in PREROUTING POSTROUTING OUTPUT; do
	
	remove_custom_rules nat $chain $CUSTOM_COMMENT
	
done


# Remove custom rules from the mangle table
for chain in PREROUTING INPUT FORWARD OUTPUT POSTROUTING; do
	
	remove_custom_rules mangle $chain $CUSTOM_COMMENT
	
done


# Print confirmation message
echo; echo-green "CBC iptables rules have been removed!"; echo-white; echo


# Shut down Docker containers
for CONTAINER_ID in $(docker ps -q); do

    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' $CONTAINER_ID | sed 's/^\/\+//')

    REPO_DIR=projects/$CONTAINER_NAME;

    if [ -d "$REPO_DIR" ]; then

    	echo; echo-cyan "Shutting down $CONTAINER_NAME ..."; echo-white; echo

    	cd $REPO_DIR

    	dockerdown

    	cd ../..

    	divider

    fi

done

if check-mariadb; then

	echo; echo-cyan "Shutting down cbc-development-setup ..."; echo-white; echo

	cd docker-stack

  dockerdown

  cd ..

fi


# Print confirmation message
echo; echo-green "All CBC containers have been shut down!"; echo-white; echo


cd $ORIG_DIR