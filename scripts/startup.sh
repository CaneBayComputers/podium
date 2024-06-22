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


# Vars
if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi

RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

WAN_IP=$(whatismyip)


# Functions
start_project() {

  PROJECT_NAME=$1

  cd "$PROJECT_NAME"

  if [[ -f "install.sh" && ! -f "is_installed" ]]; then

    echo

    source ./install.sh --dev

    echo; echo

  fi

  echo; echo-cyan "Starting up $PROJECT_NAME ..."; echo-white

  dockerup

  cd ..


  # Find D class from hosts file and use as external port access
  EXT_PORT=$(cat /etc/hosts | grep $PROJECT_NAME | cut -d'.' -f 4 | cut -d' ' -f 1)

  if [ -z "$EXT_PORT" ]; then return; fi

  RUNNING_SITES+="http://$PROJECT_NAME\n"

  RUNNING_INTERNAL+="http://$LAN_IP:$EXT_PORT ($PROJECT_NAME) \n"

  RUNNING_EXTERNAL+="http://$WAN_IP:$EXT_PORT ($PROJECT_NAME) \n"

  # Route inbound port traffic
  RULE="-p tcp --dport $EXT_PORT -j DNAT --to-destination 10.2.0.$EXT_PORT:80 -m comment --comment 'cbc-rule'"

  if iptables -t nat -C PREROUTING $RULE 2>/dev/null; then return; fi

  iptables -t nat -A PREROUTING $RULE

  # Allow forwarding of the traffic to the Docker container
  iptables -A FORWARD -p tcp -d 10.2.0.$EXT_PORT --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT -m comment --comment "cbc-rule"

  # Masquerade outgoing packets from the Docker container
  iptables -t nat -A POSTROUTING -s 10.2.0.$EXT_PORT -j MASQUERADE -m comment --comment "cbc-rule"
}

echo; echo


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

cd docker-stack

dockerup

cd ..

sleep 5


# Iterate through each CBC repo and startup
cd projects

for PROJECT_NAME in *; do

  if [ ! -d "$PROJECT_NAME" ]; then continue; fi

done

cd ..


# Allow established connections to reply
RULE="-m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment 'cbc-rule'"

if ! iptables -C FORWARD $RULE 2>/dev/null; then

  iptables -A FORWARD $RULE
  
fi


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

cd $ORIG_DIR