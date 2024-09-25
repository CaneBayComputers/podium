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
PROJECT_NAME=""

if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi

RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

WAN_IP=$(whatismyip)

if ! IPTABLES_RULES=$(iptables -t nat -L PREROUTING -v -n | grep 'cbc-rule'); then

  IPTABLES_RULES=""

fi

HOSTS=$(cat /etc/hosts)


# Functions
project_status() {

  PROJ_NAME=$1


  echo -n PROJECT:

  echo-yellow " $PROJ_NAME"


  echo-white -n PROJECT FOLDER:

  if ! [ -d "$PROJ_NAME" ]; then

    echo-red " NOT FOUND"

    echo-white -n SUGGESTION:; echo-yellow " Check spelling or clone repo"

    return 1

  else

    echo-green " FOUND"

  fi


  echo-white -n HOST ENTRY: 

  if ! HOST_ENTRY=$(printf "%s\n" "$HOSTS" | grep " $PROJ_NAME$"); then

    echo-red " NOT FOUND"

    echo-white -n SUGGESTION:; echo-yellow " Run: setup_project.sh $PROJ_NAME"

    return 1

  else

    echo-green " FOUND"

  fi


  echo-white -n DOCKER STATUS:

  if ! [ "$(docker ps -q -f name=$PROJ_NAME)" ]; then

    echo-red " NOT RUNNING"

    echo-white -n SUGGESTION:; echo-yellow " Run startup.sh script"

    return 1

  else

    echo-green " RUNNING"

  fi


  echo-white -n IPTABLES RULES:

  EXT_PORT=$(echo $HOST_ENTRY | cut -d'.' -f 4 | cut -d' ' -f 1)

  if ! printf "%s\n" "$IPTABLES_RULES" | grep "cbc-rule-$PROJ_NAME'" | grep "dpt:$EXT_PORT" > /dev/null; then

    echo-red " NOT ESTABLISHED"

    echo-white -n SUGGESTION:; echo-yellow " Run shutdown.sh then startup.sh script"

    return 1

  else

    echo-green " ESTABLISHED"

  fi

  echo-white

  echo-white -n LOCAL ACCESS:; echo-yellow " http://$PROJ_NAME"

  echo-white -n LAN ACCESS:; echo-yellow " http://$LAN_IP:$EXT_PORT"

  echo-white -n WAN ACCESS:; echo-yellow " http://$WAN_IP:$EXT_PORT"
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

  exit 1

fi


# Start CBC stack
if ! check-mariadb; then

  echo; echo-red 'Development environment is not started!'; echo-white

  echo 'Run startup.sh'

  exit 1

fi


# Iterate through projects folder
cd projects

if ! [ -z "$PROJECT_NAME" ]; then

  if project_status $PROJECT_NAME; then true; fi

  echo-white; divider

else

  for PROJECT_NAME in *; do

    if project_status $PROJECT_NAME; then true; fi

    echo-white; divider

  done

fi

cd ..

read -n 1 -r -s -p $'Press enter to continue...\n'

echo; echo

cd $ORIG_DIR