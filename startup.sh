#!/bin/bash

set -e

shopt -s expand_aliases

source ~/.bash_aliases

repos

REPOS=( cbc-development-setup certbot-bash-wrapper cbc-docker-stack cbc-docker-php7-nginx cbc-docker-php8-nginx )

for REPO in "${REPOS[@]}"

do

	printf "\n------- $REPO\n"

	cd $REPO

	gpull

	cd ..

done

echo

repos

cd cbc-development-setup

if ! [ -f is_installed ]; then

  source ./install.sh

fi

if [ "$(docker container inspect -f '{{.State.Running}}' cbc-mariadb)" != "true" ]; then upcbcstack; fi

repos

cd cbc-laravel-php7

if [ "$(docker container inspect -f '{{.State.Running}}' cbc-laravel-php7)" != "true" ]; then dockerup; fi

cd ..

echo

cd cbc-laravel-php8

if [ "$(docker container inspect -f '{{.State.Running}}' cbc-laravel-php8)" != "true" ]; then dockerup; fi

cd ..

echo

read -n 1 -r -s -p $'Press enter to continue...\n'