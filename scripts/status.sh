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
if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi

RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

WAN_IP=$(whatismyip)

IPTABLES_RULES=$(iptables -L -v -n | grep 'cbc-rule')


# Functions
project_status() {

  PROJECT_NAME=$1

  if echo "$IPTABLES_RULES" | grep "$PROJECT_NAME" > /dev/null; then

    RUNNING_SITES+="http://$PROJECT_NAME\n"

    RUNNING_INTERNAL+="http://$LAN_IP:$EXT_PORT ($PROJECT_NAME) \n"

    RUNNING_EXTERNAL+="http://$WAN_IP:$EXT_PORT ($PROJECT_NAME) \n"

  fi

}


# Main

# Do not run as root
if [[ "$(whoami)" == "root" ]]; then

  echo-red "Do NOT run with sudo!"; echo-white; echo

  exit 1

fi


# Check if this environment is installed
if ! [ -f is_installed ]; then

  echo; echo-red 'Development environment has not been installed!'; echo-white

  echo 'Run install.sh'

  exit 0

fi


# Start CBC stack
if ! check-cbc-mariadb; then

  echo; echo-red 'Development environment is not started!'; echo-white

  echo 'Run startup.sh'

  exit 0

fi


# Iterate through projects folder
cd projects

if ! [ -z "$PROJECT_NAME" ]; then

  project_status $PROJECT_NAME

else

  for PROJECT_NAME in *; do

    project_status $PROJECT_NAME

  done

fi

cd ..


# Output info
echo; echo

echo-green "The following sites are now running!"; echo-white; divider

echo-cyan "
--- Local access ---
Use these addresses if accessing from within the machine itself. Use the virtual machine's browser if using a VM. This will also work if you installed directly onto your Linux computer desktop."

echo-white; echo -e  $RUNNING_SITES; divider

echo-cyan "
--- LAN access ---
Accessible from another device within the same network. If using a virtual machine it needs to be set up as a Bridged adapter so your local network sees it as a stand-alone device which will give it its own IP address. If installed directly onto your Linux desktop these should just work as-is."

echo-white; echo -e $RUNNING_INTERNAL; divider

echo-cyan "
--- WAN access ---
If installed on a cloud server the address should work IF the server has a public IP address AND these ports are publicly accessible through a firewall, ie. the ports are open."

echo-white; echo -e $RUNNING_EXTERNAL; divider

read -n 1 -r -s -p $'Press enter to continue...\n'

echo; echo