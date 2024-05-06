#!/bin/bash

set -e

printf "\n------- cbc-development-setup\n"

cd ~/repos/cbc-development-setup

git pull

if ! [ -f is_installed ]; then

  source ./install.sh

else

	cd ~/repos

	REPOS=( certbot-bash-wrapper cbc-docker-stack cbc-docker-php7-nginx cbc-docker-php8-nginx cbc-laravel-php7 cbc-laravel-php8 )

	for REPO in "${REPOS[@]}"

	do

		printf "\n------- $REPO\n"

		cd $REPO

		git pull

		cd ..

	done

	cd cbc-docker-stack

	docker compose up -d

	cd ..

	cd cbc-laravel-php7

	docker compose up -d

	cd ..

	echo

	cd cbc-laravel-php8

	docker compose up -d

	cd ..

fi

echo; echo

read -n 1 -r -s -p $'Press enter to continue...\n'