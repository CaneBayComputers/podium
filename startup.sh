#!/bin/bash

# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e

source .bash_aliases

shopt -s expand_aliases

if [[ "$(whoami)" == "root" ]]; then echo-red "Do NOT run with sudo!"; exit 1; fi

if ! [ -f is_installed ]; then

  echo-red "Setup is not installed!"

  echo-white "Please run: ./install.sh"

  exit 1

fi

upcbcstack

sleep 5

repos

RUNNING_PORTS=""

for DIR in *; do

	if [ -d "$DIR" ] && [ "$DIR" != "cbc-docker-stack" ]; then

		cd "$DIR"

		if [ -f "docker-compose.yaml" ]; then

			echo; echo

			if [ -f "is_installed" ]; then

				source ./install.sh --dev

			else

				dockerup

			fi

			echo; echo

			# Find D class from hosts file and use as external port access
			EXT_PORT=$(cat /etc/hosts | grep $DIR | cut -d'.' -f 4 | cut -d' ' -f 1)

			RUNNING_PORTS+="$DIR:$EXT_PORT\n"

			# Route inbound port traffic
			sudo iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80

			# Allow forwarding of the traffic to the Docker container
			sudo iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -j ACCEPT

		fi

		cd ..

	fi

done

echo; echo

echo-green "The following sites are now running!"

echo-white $RUNNING_PORTS

echo; echo-green "
IMPORTANT:
If you are trying to access these sites from outside a server or VM
make sure you replace the site name with the external IP address and
ensure the corresponding port is open."

echo-white; echo

read -n 1 -r -s -p $'Press enter to continue...\n'