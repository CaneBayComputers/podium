#!/bin/bash

# In the Startup Applications manager enter this command to run this script to start up repos:
# gnome-terminal -- bash -c "/home/dev/repos/cbc-development-setup/startup.sh; exec bash"

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases

echo; echo


# Vars
if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi


# Functions
start_project() {

  PROJECT_NAME=$1

  cd "$PROJECT_NAME"

  if ! [ -f docker-compose.yaml ]; then

    echo-red 'No docker-compose.yaml file found!'

    echo-white 'Possibly not installed. Skipping ...'

    cd ..

    return 1

  fi

  echo; echo-cyan "Starting up $PROJECT_NAME ..."; echo-white

  dockerup

  cd ..


  # Find D class from hosts file and use as external port access
  EXT_PORT=$(cat /etc/hosts | grep $PROJECT_NAME | cut -d'.' -f 4 | cut -d' ' -f 1)

  if [ -z "$EXT_PORT" ]; then return; fi

  # Route inbound port traffic
  RULE="-p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80 -m comment --comment 'cbc-rule-$PROJECT_NAME'"

  # If this rule already exists it's probably still running in Docker
  if iptables -t nat -C PREROUTING $RULE 2>/dev/null; then return; fi

  iptables -t nat -A PREROUTING $RULE

  # Allow forwarding of the traffic to the Docker container
  iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "cbc-rule-$PROJECT_NAME"

  # Masquerade outgoing packets from the Docker container
  iptables -t nat -A POSTROUTING -s 10.2.0.$EXT_PORT -j MASQUERADE -m comment --comment "cbc-rule-$PROJECT_NAME"
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

  echo 'Run: ./install.sh'

  exit 0

fi

divider


# Start CBC stack
echo; echo-cyan "Starting services ..."; echo-white; echo

if ! check-cbc-mariadb; then

  cd docker-stack

  dockerup

  cd ..

  sleep 5

fi


# Start projects either just one by name or all in the projects directory
cd projects

if ! [ -z "$PROJECT_NAME" ]; then

   start_project $PROJECT_NAME

else

  for PROJECT_NAME in *; do

    if [ ! -d "$PROJECT_NAME" ]; then continue; fi

  done

fi

cd ..


# Allow established connections to reply
RULE="-m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment 'cbc-rule'"

if ! iptables -C FORWARD $RULE 2>/dev/null; then

  iptables -A FORWARD $RULE
  
fi

cd $ORIG_DIR