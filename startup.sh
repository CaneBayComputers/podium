#!/bin/bash

set -e

shopt -s expand_aliases

source ~/.bash_aliases

repos

REPOS=( cbc-development-setup certbot-bash-wrapper cbc-docker-stack cbc-docker-php7-nginx cbc-docker-php8-nginx cbc-laravel-php7 cbc-laravel-php8 )

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

upcbcstack

repos

cd cbc-laravel-php7

dockerup

cd ..

echo

cd cbc-laravel-php8

dockerup

cd ..

echo

read -n 1 -r -s -p $'Press enter to continue...\n'