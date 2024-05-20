#!/bin/bash

# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

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

	echo; echo

	cd cbc-docker-stack

	sudo docker compose up -d

	cd ..

	# Iterate through the items in the current directory
	for DIR in *; do

		# Check if DIR is a directory
		if [ -d "$DIR" ] && [ "$DIR" != "cbc-docker-stack" ]; then

			# Change into the directory
			cd "$DIR"

			# Check if the file exists in this directory
			if [ -f "docker-compose.yaml" ]; then

				echo; echo

				sudo docker compose up -d

				# Find D class from hosts file and use as external port access
				EXT_PORT=$(cat /etc/hosts | grep $DIR | cut -d'.' -f 4 | cut -d' ' -f 1)

				echo $EXT_PORT

				# Route inbound port traffic
				sudo iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80

				# Allow forwarding of the traffic to the Docker container
				sudo iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -j ACCEPT

			fi

			# Return to the original directory
			cd ..

		fi

	done

	cd ..

fi

echo; echo

read -n 1 -r -s -p $'Press enter to continue...\n'