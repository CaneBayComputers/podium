#!/bin/bash

# In the Startup Applications manager enter this command to run this script to start up repos:
# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e

shopt -s expand_aliases

cd ~/repos/cbc-development-setup

source .bash_aliases

if [[ "$(whoami)" == "root" ]]; then

	echo; echo-red "Do NOT run with sudo!"; echo-white; echo

	exit 1

fi

echo; echo-green 'Pulling cbc-development-setup ...'; echo-white; echo

gpull

divider

repos

REPOS=( certbot-bash-wrapper cbc-docker-stack cbc-laravel-php7 cbc-laravel-php8 )

for REPO in "${REPOS[@]}"

do

	echo; echo-green "Pulling $REPO ..."; echo-white; echo

	cd $REPO

	gpull

	divider

	cd ..

done

repos

cd cbc-development-setup

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
echo; echo-cyan "All iptables rules have been flushed, and default policies set to ACCEPT."; echo-white

if ! dockerls | grep cbc-mariadb > /dev/null; then

	echo

	upcbcstack

	sleep 5

fi

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
	iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80

	# Allow forwarding of the traffic to the Docker container
	iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -j ACCEPT

fi

cd ..

done

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
a virtual machine it needs to be set up as a Host-only adapter
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

echo-green "
IMPORTANT:
If you are trying to access these sites from outside a server or VM
make sure you replace the site name with the external IP address and
ensure the corresponding port is open."

echo-white; echo

read -n 1 -r -s -p $'Press enter to continue...\n'

echo; echo