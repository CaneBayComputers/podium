#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases


# Main
cd scripts

source start_services.sh

cd ..


# Env vars
source docker-stack/.env


# Function to display usage
usage() {
    echo "Usage: $0 <repository> [project_name]"
    exit 1
}


# Check if repository argument is provided
if [ -z "$1" ]; then
    echo "Error: Repository is required."
    usage
fi


# Assign arguments to variables
REPOSITORY=$1
PROJECT_NAME=${2:-}


# Set project name
if [ -z "$PROJECT_NAME" ]; then

    PROJECT_NAME=$(basename -s .git "$REPOSITORY")

fi


# Display the provided arguments
echo "Repository: $REPOSITORY"

echo "Project Name: $PROJECT_NAME"


# Convert to lowercase, replace spaces with dashes, and remove non-alphanumeric characters
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-_')


# Get a random D class number and make sure it doesn' already exist in hosts file
echo -n "Docker IP Address: "

while true; do

    D_CLASS=$((RANDOM % (250 - 100 + 1) + 100))

    IP_ADDRESS="$VPC_SUBNET.$D_CLASS"

    if ! cat /etc/hosts | grep "$IP_ADDRESS"; then break; fi

done

# Write the new project host and Docker IP address
while true; do

    HOST_LINE=$(cat /etc/hosts | grep -n -m 1 $PROJECT_NAME | cut -d : -f 1)

    if ! [[ -z $HOST_LINE ]]; then

        sudo sed -i "${HOST_LINE}d" /etc/hosts

    else

        break

    fi

done


# Enter new Docker IP address
echo "$IP_ADDRESS      $PROJECT_NAME" | sudo tee -a /etc/hosts


# Clone repository
echo; echo

cd projects

git clone $REPOSITORY $PROJECT_NAME


# Set up Docker compose file
cd $PROJECT_NAME

cp -f ../../extras/docker-compose.yaml .

sed -i "s/IPV4_ADDRESS/$IP_ADDRESS/g" docker-compose.yaml

sed -i "s/CONTAINER_NAME/$PROJECT_NAME/g" docker-compose.yaml

cd ../..


# Start Docker instance
cd scripts

source startup.sh --no-status $PROJECT_NAME

cd ..


# Install Composer libraries
cd projects/$PROJECT_NAME

if ! [ -d "vendor" ]; then

    composer-docker install

fi


# Install and setup .env file
if ! [ -f .env ]; then

    cp -f .env.example .env

    sed -i "/^#\?APP_NAME=/c\APP_NAME=$PROJECT_NAME" .env

    sed -i "/^#\?APP_URL=/c\APP_URL=http:\/\/$PROJECT_NAME" .env

    sed -i "/^#\?DB_CONNECTION=/c\DB_CONNECTION=mysql" .env

    sed -i "/^#\?DB_HOST=/c\DB_HOST=mariadb" .env

    sed -i "/^#\?DB_DATABASE=/c\DB_DATABASE=$PROJECT_NAME" .env

    art-docker key:generate

    echo; echo

fi







# if ! mysql -h"cbc-mariadb" -u"root" -e "USE $PROJECT_NAME_SNAKE;" 2>/dev/null; then

#     mysql -h"cbc-mariadb" -u"root" -e "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME_SNAKE;"

#     echo; echo

# fi

# art-docker migrate

# echo; echo

# art-docker db:seed

# echo; echo



# Older Laravel
# find storage/framework -maxdepth 1 -type d -exec chmod 777 {} +

# chmod 777 storage/logs

# setfacl -m "default:group::rw" storage/logs

# chmod 777 storage/temp

# chmod 777 bootstrap/cache




# Newer Laravel
# find storage/framework -maxdepth 1 -type d -exec chmod 777 {} +

# chmod 777 storage/logs

# setfacl -m "default:group::rw" storage/logs

# chmod 777 bootstrap/cache





# cd ../../scripts

# source startup.sh $PROJECT_NAME

# cd ../projects/$PROJECT_NAME






# Return to original directory
cd $ORIG_DIR