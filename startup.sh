#!/bin/bash

# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e

source .bash_aliases

shopt -s expand_aliases

if ! [ -f is_installed ]; then

  echo-red "Setup is not installed!"

  echo-white "Please run: ./install.sh"

  exit 1

fi

cd ~/repos

REPOS=( cbc-development-setup certbot-bash-wrapper cbc-docker-stack cbc-laravel-php7 cbc-laravel-php8 )

for REPO in "${REPOS[@]}"

do

	printf "\n------- $REPO\n"

	if ! cd $REPO; then

		git clone https://github.com/CaneBayComputers/$REPO.git

	else

		if git pull; then true; fi

		cd ..

	fi

done

echo; echo

cd cbc-docker-stack

sudo docker compose up -d

cd ..

RUNNING_PORTS=""

for DIR in *; do

	if [ -d "$DIR" ] && [ "$DIR" != "cbc-docker-stack" ]; then

		cd "$DIR"

		if [ -f "docker-compose.yaml" ]; then

			echo; echo

			if [[ -f "install.sh" && ! -f "is_installed" ]]; then

				source ./install.sh --dev

			fi

			sudo docker compose up -d

			# Find D class from hosts file and use as external port access
			EXT_PORT=$(cat /etc/hosts | grep $DIR | cut -d'.' -f 4 | cut -d' ' -f 1)

			RUNNING_PORTS+="$DIR:$EXT_PORT\n"

			# Route inbound port traffic
			sudo iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80

			# Allow forwarding of the traffic to the Docker container
			sudo iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -j ACCEPT

			# Create database and run any migrations
			REPO_NAME_SNAKE=$(echo "$DIR" | tr '[:upper:]' '[:lower:]' | tr '-' '_')

			if ! mysql -h"cbc-mariadb" -u"root" -e "USE $REPO_NAME_SNAKE;" 2>/dev/null; then

        mysql -h"cbc-mariadb" -u"root" -e "CREATE DATABASE IF NOT EXISTS $REPO_NAME_SNAKE;"

    	fi

    	art-docker migrate

		fi

		# Return to the original directory
		cd ..

	fi

done

cd ..

echo; echo

echo-green "The following sites are now running!"

echo-white $RUNNING_PORTS

echo "
IMPORTANT:
If you are trying to access these sites from outside a server or VM
make sure you replace the site name with the external IP address and
ensure the corresponding port is open."

read -n 1 -r -s -p $'Press enter to continue...\n'