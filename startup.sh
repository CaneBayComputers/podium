#!/bin/bash

# In the Startup Applications manager enter this command to run this script to start up repos:
# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e

shopt -s expand_aliases

cd "$(dirname "$0")"

DEV_DIR=$(pwd)

source .bash_aliases

echo; echo

if [[ "$(whoami)" == "root" ]]; then

	echo-red "Do NOT run with sudo!"; echo-white; echo

	exit 1

fi

echo-cyan 'Pulling cbc-development-setup ...'; echo-white; echo

git pull

if ! [ -f is_installed ]; then

	echo

  source ./install.sh

  exit 0

fi

divider

repos

REPOS=( certbot-bash-wrapper cbc-docker-stack cbc-laravel-php7 cbc-laravel-php8 )

for REPO in "${REPOS[@]}"

do

	echo; echo-cyan "Pulling $REPO ..."; echo-white; echo

	cd $REPO

	gpull

	divider

	cd ..

done


# Remove CBC iptables rules and shutdown Docker containers
cd cbc-development-setup

source ./shutdown.sh


# Start CBC stack
echo; echo-cyan "Starting cbc-development-setup ..."; echo-white; echo

upcbcstack

sleep 5


# Iterate through each CBC repo and startup
repos

RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

WAN_IP=$(whatismyip)

for REPO_NAME in *; do

	if [ ! -d "$REPO_NAME" ]; then continue; fi

	if [ "$REPO_NAME" = "cbc-docker-stack" ]; then continue; fi

	if [ "$REPO_NAME" = "certbot-bash-wrapper" ]; then continue; fi

	if [ "$REPO_NAME" = "cbc-development-setup" ]; then continue; fi

	cd "$REPO_NAME"

	if [[ -f "install.sh" && ! -f "is_installed" ]]; then

		echo

		source ./install.sh --dev

		echo; echo

	fi

	echo; echo-cyan "Starting up $REPO_NAME ..."; echo-white

	if [ -f "docker-compose.yaml" ]; then

		if ! dockerls | grep $REPO_NAME > /dev/null; then

			dockerup

		fi

	fi

	# Find D class from hosts file and use as external port access
	EXT_PORT=$(cat /etc/hosts | grep $REPO_NAME | cut -d'.' -f 4 | cut -d' ' -f 1)

	if ! [ -z "$EXT_PORT" ]; then

		RUNNING_SITES+="http://$REPO_NAME\n"

		RUNNING_INTERNAL+="http://$LAN_IP:$EXT_PORT ($REPO_NAME) \n"

		RUNNING_EXTERNAL+="http://$WAN_IP:$EXT_PORT ($REPO_NAME) \n"

		# Route inbound port traffic
		iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80 -m comment --comment "cbc-rule"

		# Allow forwarding of the traffic to the Docker container
		iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "cbc-rule"

		# Masquerade outgoing packets from the Docker container
		iptables -t nat -A POSTROUTING -s 10.2.0.$EXT_PORT -j MASQUERADE -m comment --comment "cbc-rule"

	fi

	# Allow established connections to reply
	iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "cbc-rule"

	cd ..

done

# Redirect stdout (file descriptor 1) and stderr (file descriptor 2) to tee
exec > >(tee ~/repos/cbc-development-setup/startup.log) 2>&1

echo; echo

echo-green "The following sites are now running!"; echo-white; divider

echo-cyan "
--- Local access:

Use these addresses if accessing from within the machine itself.
Use the virtual machine's browser if using a VM. This will also
work if you installed directly onto your Linux computer desktop."

echo-white; echo -e  $RUNNING_SITES; divider

echo-cyan "
--- LAN access:

Accessible from another device within the same network. If using
a virtual machine it needs to be set up as a Bridged adapter
so your local network sees it as a stand-alone device which will
give it its own IP address. If installed directly onto your Linux
desktop these should just work as-is."

echo-white; echo -e $RUNNING_INTERNAL; divider

echo-cyan "
--- WAN access:

If installed on a cloud server the address should work IF the
server has a public IP address AND these ports are publicly
accessible through a firewall, ie. the ports are open."

echo-white; echo -e $RUNNING_EXTERNAL; divider

echo-yellow "
IMPORTANT:
If you are trying to access these sites from outside a server or VM
make sure you replace the site name with the external IP address and
ensure the corresponding port is open."

echo-white; echo

read -n 1 -r -s -p $'Press enter to continue...\n'

echo; echo