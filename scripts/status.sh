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
RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

WAN_IP=$(whatismyip)


# Functions


# Main











RUNNING_SITES+="http://$PROJECT_NAME\n"

RUNNING_INTERNAL+="http://$LAN_IP:$EXT_PORT ($PROJECT_NAME) \n"

RUNNING_EXTERNAL+="http://$WAN_IP:$EXT_PORT ($PROJECT_NAME) \n"




alias listcbc='CUR_PWD=$(pwd); cbc-development; if [ -f startup.log ]; then cat startup.log; else echo-red "CBC not started!"; echo-white "Run ./startup.sh"; fi; cd $CUR_PWD'

# Redirect stdout (file descriptor 1) and stderr (file descriptor 2) to tee
exec > >(tee scripts/startup.log) 2>&1

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