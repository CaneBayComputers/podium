#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh


# Pre check to make sure development is installed
source "$DEV_DIR/scripts/pre_check.sh"


# Env vars
source docker-stack/.env

# Database engine can be passed as second parameter, default to mariadb
DATABASE_ENGINE="${2:-mariadb}"

# Function to display usage
usage() {

    echo "Usage: $0 <project_name>"
    
    exit 1
}


# Check if repository argument is provided
if [ -z "$1" ]; then

    echo "Error: Project name is required."

    usage
fi


# Assign arguments to variables
PROJECT_NAME=$1

# Use the configured projects directory
PROJECTS_DIR=$(get_projects_dir)
PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"


# Check for project folder existence
if ! [ -d "$PROJECT_DIR" ]; then

    echo-red "Project folder does not exist!"; echo-white

    exit 1

fi


# Start micro services
source "$DEV_DIR/scripts/start_services.sh"


# Shutdown project in case it is running
source "$DEV_DIR/scripts/shutdown.sh" $PROJECT_NAME


# Enter into project and get PHP version
cd "$PROJECT_DIR"

pwd; echo

if grep -q '"php":\s*"^7' composer.json; then

    PHP_VERSION="7"

elif grep -q '"php":\s*"^8' composer.json; then

    PHP_VERSION="8"

else

    echo-red "ERROR: Could not determine PHP version requirement from composer.json. Exiting."; echo-white

    exit 1

fi


# Convert dashes to underscores
PROJECT_NAME_SNAKE=$(echo "$PROJECT_NAME" | sed 's/-/_/g')


# Get a random D class number and make sure it doesn' already exist in hosts file
echo -n "Docker IP Address: "

while true; do

    D_CLASS=$((RANDOM % (250 - 100 + 1) + 100))

    IP_ADDRESS="$VPC_SUBNET.$D_CLASS"

    if ! cat /etc/hosts | grep "$IP_ADDRESS"; then break; fi

done

# Write the new project host and Docker IP address
while true; do

    HOST_LINE=$(grep -n -m 1 " $PROJECT_NAME$" /etc/hosts | cut -d : -f 1)

    if ! [[ -z $HOST_LINE ]]; then

        sudo-podium-sed "${HOST_LINE}d" /etc/hosts

    else

        break

    fi

done


# Enter new Docker IP address
echo "$IP_ADDRESS      $PROJECT_NAME" | sudo tee -a /etc/hosts

echo


# Set up Docker compose file
unalias cp 2>/dev/null || true

# Use absolute path to docker-stack directory
PODIUM_DIR="$DEV_DIR"
cp -f "$PODIUM_DIR/docker-stack/docker-compose.project.yaml" docker-compose.yaml

podium-sed "s/IPV4_ADDRESS/$IP_ADDRESS/g" docker-compose.yaml

podium-sed "s/CONTAINER_NAME/$PROJECT_NAME/g" docker-compose.yaml

podium-sed "s/STACK_ID/$STACK_ID/g" docker-compose.yaml

podium-sed "s/PHP_VERSION/$PHP_VERSION/g" docker-compose.yaml

podium-sed "s/PROJECT_PORT/$D_CLASS/g" docker-compose.yaml

if [ -d "public" ]; then

    podium-sed "s/PUBLIC//g" docker-compose.yaml

else

    podium-sed "s/PUBLIC/\/public/g" docker-compose.yaml

fi

# Stay in project directory for Docker operations
# Start Docker instance
echo; echo-cyan "Starting up $PROJECT_NAME ..."; echo-white

if ! [ -f docker-compose.yaml ]; then
    echo-red 'No docker-compose.yaml file found!'
    echo-white 'Project setup incomplete. Exiting.'
    exit 1
fi

# Start the container
dockerup

sleep 5

echo-green "Project $PROJECT_NAME started successfully!"


# Install Composer libraries
cd "$PROJECT_DIR"

echo-cyan "Current directory: $(pwd)"; echo-white

if [ -f "composer.json" ]; then

    echo-cyan "Installing vendor libs with composer ..."; echo-white

    composer-docker install

    echo-green "Vendor libs installed!"; echo-white

fi


# Install and setup .env file
unalias cp 2>/dev/null || true

if [ -f ".env.example" ]; then

    echo-cyan "Setting up .env file ..."; echo-white

    cp -f .env.example .env

    APP_KEY="base64:$(head -c 32 /dev/urandom | base64)"

    podium-sed "/^#*\s*APP_NAME=/c\APP_NAME=$PROJECT_NAME" .env
    podium-sed "/^#*\s*APP_KEY=/c\APP_KEY=$APP_KEY" .env
    podium-sed "/^#*\s*APP_URL=/c\APP_URL=http:\/\/$PROJECT_NAME" .env
    # Configure database connection based on selected engine
    case $DATABASE_ENGINE in
        "postgresql")
            podium-sed "/^#*\s*DB_CONNECTION=/c\DB_CONNECTION=pgsql" .env
            podium-sed "/^#*\s*DB_HOST=/c\DB_HOST=postgres" .env
            podium-sed "/^#*\s*DB_PORT=/c\DB_PORT=5432" .env
            podium-sed "/^#*\s*DB_DATABASE=/c\DB_DATABASE=$PROJECT_NAME_SNAKE" .env
            podium-sed "/^#*\s*DB_USERNAME=/c\DB_USERNAME=postgres" .env
            podium-sed "/^#*\s*DB_PASSWORD=/c\DB_PASSWORD=postgres" .env
            ;;
        "mongodb")
            podium-sed "/^#*\s*DB_CONNECTION=/c\DB_CONNECTION=mongodb" .env
            podium-sed "/^#*\s*DB_HOST=/c\DB_HOST=mongo" .env
            podium-sed "/^#*\s*DB_PORT=/c\DB_PORT=27017" .env
            podium-sed "/^#*\s*DB_DATABASE=/c\DB_DATABASE=$PROJECT_NAME_SNAKE" .env
            podium-sed "/^#*\s*DB_USERNAME=/c\DB_USERNAME=root" .env
            podium-sed "/^#*\s*DB_PASSWORD=/c\DB_PASSWORD=root" .env
            ;;
        *)
            podium-sed "/^#*\s*DB_CONNECTION=/c\DB_CONNECTION=mysql" .env
            podium-sed "/^#*\s*DB_HOST=/c\DB_HOST=mariadb" .env
            podium-sed "/^#*\s*DB_PORT=/c\DB_PORT=3306" .env
            podium-sed "/^#*\s*DB_DATABASE=/c\DB_DATABASE=$PROJECT_NAME_SNAKE" .env
            podium-sed "/^#*\s*DB_USERNAME=/c\DB_USERNAME=root" .env
            podium-sed "/^#*\s*DB_PASSWORD=/c\DB_PASSWORD=" .env
            ;;
    esac
    podium-sed "/^#*\s*CACHE_DRIVER=/c\CACHE_DRIVER=redis" .env
    podium-sed "/^#*\s*SESSION_DRIVER=/c\SESSION_DRIVER=redis" .env
    podium-sed "/^#*\s*QUEUE_CONNECTION=/c\QUEUE_CONNECTION=redis" .env
    podium-sed "/^#*\s*CACHE_STORE=/c\CACHE_STORE=redis" .env
    podium-sed "/^#*\s*CACHE_PREFIX=/c\CACHE_PREFIX=$PROJECT_NAME" .env
    podium-sed "/^#*\s*MEMCACHED_HOST=/c\MEMCACHED_HOST=memcached" .env
    podium-sed "/^#*\s*REDIS_HOST=/c\REDIS_HOST=redis" .env
    # Email configuration removed - configure SMTP in your project's .env as needed
    echo "" >> .env
    echo "XDG_CONFIG_HOME=/usr/share/nginx/html/storage/app" >> .env

    echo-green "The .env file has been created!"; echo-white

# Install config.inc file
elif [ -f "config.example.inc.php" ]; then

    cp -f config.example.inc.php config.inc.php

    podium-sed "s/DB_HOSTNAME/mariadb/" config.inc.php
    podium-sed "s/DB_USERNAME/root/" config.inc.php
    podium-sed "s/DB_PASSWORD//" config.inc.php
    podium-sed "s/DB_NAME/$PROJECT_NAME_SNAKE/" config.inc.php

# Install wp-config file
elif [ -f "wp-config-sample.php" ]; then

    echo-cyan "Configuring WordPress for containerized setup..."
    
    # Set database host based on engine
    case $DATABASE_ENGINE in
        "postgresql")
            DB_HOST_VALUE="postgres"
            ;;
        "mongodb")
            DB_HOST_VALUE="mongo"
            ;;
        *)
            DB_HOST_VALUE="mariadb"
            ;;
    esac
    
    # Create wp-config.php with database connection
    cat > wp-config.php << EOF
<?php
define('DB_NAME', '$PROJECT_NAME_SNAKE');
define('DB_USER', 'root');
define('DB_PASSWORD', '');
define('DB_HOST', '$DB_HOST_VALUE');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY',         '$(openssl rand -base64 32)');
define('SECURE_AUTH_KEY',  '$(openssl rand -base64 32)');
define('LOGGED_IN_KEY',    '$(openssl rand -base64 32)');
define('NONCE_KEY',        '$(openssl rand -base64 32)');
define('AUTH_SALT',        '$(openssl rand -base64 32)');
define('SECURE_AUTH_SALT', '$(openssl rand -base64 32)');
define('LOGGED_IN_SALT',   '$(openssl rand -base64 32)');
define('NONCE_SALT',       '$(openssl rand -base64 32)');

\$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF
    
    echo-green "WordPress configuration created!"
    echo-white
    echo-cyan "WordPress will be automatically set up when the container starts."
    echo-white "After setup completes, visit http://$PROJECT_NAME to complete the WordPress installation."

fi

echo; echo


# Make storage writable for all
if [ -d "storage" ]; then

    echo-cyan 'Setting folder permissions ...'; echo-white

    find storage -type d -exec chmod 777 {} +

    find storage -type d -exec setfacl -m "default:group::rw" {} +

    echo-green 'Storage folder permissions set!'; echo-white

fi

# Create new database, run migration and seed
echo-cyan "Creating database $PROJECT_NAME_SNAKE ..."; echo-white

mysql -h"mariadb" -u"root" -e "CREATE DATABASE IF NOT EXISTS $PROJECT_NAME_SNAKE;"

echo-green 'Database created!'; echo-white

if [ -f "artisan" ]; then

    echo-cyan 'Running migrations ...'; echo-white

    if art-docker migrate:fresh; then

        echo-green 'Migrations successful'; echo-white

        echo-cyan 'Seeding database ...'; echo-white

        if art-docker db:seed; then

            echo-green 'Database seeded!'; echo-white

        fi

    fi

elif [ -f "create_tables.sql" ]; then

    echo-cyan 'Creating tables ...'; echo-white

    mysql -h"mariadb" -u"root" $PROJECT_NAME_SNAKE < create_tables.sql

fi

echo; echo


# Show status of running Docker project
source "$DEV_DIR/scripts/status.sh" $PROJECT_NAME


# Return to original directory
cd $ORIG_DIR
