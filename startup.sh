#!/bin/bash

# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e

source ~/repos/cbc-development-setup/.bash_aliases

shopt -s expand_aliases

if [[ "$(whoami)" == "root" ]]; then

	echo; echo-red "Do NOT run with sudo!"; echo

	exit 1

fi

if ! [ -f is_installed ]; then

  source ./install.sh

  exit 0

fi

# Flush all rules in all chains
iptables -F    # Flush all the rules in the filter table
iptables -X    # Delete all user-defined chains in the filter table
iptables -Z    # Zero all packet and byte counters in all chains

# If you are using the nat or mangle tables, you should also flush and delete their rules and chains
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z

# Set default policies to ACCEPT (this step is crucial to avoid locking yourself out)
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Print confirmation message
echo; echo-cyan "All iptables rules have been flushed, and default policies set to ACCEPT."

echo-white; echo

if ! dockerls | grep cbc-mariadb > /dev/null; then

	upcbcstack

	sleep 5

fi

repos

RUNNING_PORTS=""

for REPO_NAME in *; do

if [ ! -d "$REPO_NAME" ]; then continue; fi

if [ "$REPO_NAME" = "cbc-docker-stack" ]; then continue; fi

if [ "$REPO_NAME" = "certbot-bash-wrapper" ]; then continue; fi

if [ "$REPO_NAME" = "cbc-development-setup" ]; then continue; fi

cd "$REPO_NAME"

if [[ -f "install.sh" && ! -f "is_installed" ]]; then

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

	RUNNING_PORTS+="$REPO_NAME:$EXT_PORT\n"

	# Route inbound port traffic
	iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80

	# Allow forwarding of the traffic to the Docker container
	iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -j ACCEPT

fi

cd ..

done

echo; echo

echo-green "The following sites are now running!"

echo-white; printf $RUNNING_PORTS

echo; echo-green "

IMPORTANT:
If you are trying to access these sites from outside a server or VM
make sure you replace the site name with the external IP address and
ensure the corresponding port is open."

echo-white; echo

read -n 1 -r -s -p $'Press enter to continue...\n'

echo; echo