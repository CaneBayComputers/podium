#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

# Get projects directory
PROJECTS_DIR="$(get_projects_dir)"

source scripts/functions.sh

# Main
source "$DEV_DIR/scripts/pre_check.sh"


# Function to display usage
usage() {
    echo "Usage: $0 <project_name> [organization]"
    echo "Creates a new Laravel or WordPress project"
    exit 1
}


# Check if repository argument is provided
if [ -z "$1" ]; then
    echo "Error: Project name is required."
    usage
fi


# Assign arguments to variables
PROJECT_NAME=$1

ORGANIZATION=${2:-}


# Convert to lowercase, replace spaces with dashes, and remove non-alphanumeric characters
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-_')


# Project type selection
echo; echo-cyan "What type of project would you like to create?"
echo-white "1) Laravel (PHP Framework)"
echo-white "2) WordPress (CMS)"
echo; echo-yellow -n "Enter your choice (1-2): "
read PROJECT_TYPE_CHOICE

case $PROJECT_TYPE_CHOICE in
    1)
        PROJECT_TYPE="laravel"
        echo; echo-cyan "Laravel project selected!"
        
        # Laravel version selection
        echo; echo-cyan "Which Laravel version would you like to use?"
        echo-white "1) Laravel 12.x (Latest - Recommended)"
        echo-white "2) Laravel 11.x (LTS)"
        echo-white "3) Laravel 10.x (Previous LTS)"
        echo-white "4) Custom version"
        echo; echo-yellow -n "Enter your choice (1-4): "
        read LARAVEL_VERSION_CHOICE
        
        case $LARAVEL_VERSION_CHOICE in
            1)
                CUR_LARAVEL_BRANCH="12.x"
                echo-green "Laravel 12.x selected!"
                ;;
            2)
                CUR_LARAVEL_BRANCH="11.x"
                echo-green "Laravel 11.x selected!"
                ;;
            3)
                CUR_LARAVEL_BRANCH="10.x"
                echo-green "Laravel 10.x selected!"
                ;;
            4)
                echo; echo-yellow -n "Enter Laravel version (e.g., 11.x, 10.x): "
                read CUSTOM_LARAVEL_VERSION
                CUR_LARAVEL_BRANCH="$CUSTOM_LARAVEL_VERSION"
                echo-green "Laravel $CUSTOM_LARAVEL_VERSION selected!"
                ;;
            *)
                echo-yellow "Invalid choice. Defaulting to Laravel 12.x"
                CUR_LARAVEL_BRANCH="12.x"
                ;;
        esac
        ;;
    2)
        PROJECT_TYPE="wordpress"
        echo; echo-cyan "WordPress project selected!"
        
        # WordPress version selection
        echo; echo-cyan "Which WordPress version would you like to use?"
        echo-white "1) Latest WordPress (Recommended)"
        echo-white "2) WordPress 6.4 (Previous version)"
        echo-white "3) WordPress 6.3"
        echo; echo-yellow -n "Enter your choice (1-3): "
        read WP_VERSION_CHOICE
        
        case $WP_VERSION_CHOICE in
            1)
                WP_VERSION="latest"
                echo-green "Latest WordPress selected!"
                ;;
            2)
                WP_VERSION="6.4"
                echo-green "WordPress 6.4 selected!"
                ;;
            3)
                WP_VERSION="6.3"
                echo-green "WordPress 6.3 selected!"
                ;;
            *)
                echo-yellow "Invalid choice. Defaulting to latest WordPress"
                WP_VERSION="latest"
                ;;
        esac
        ;;
    *)
        echo-red "Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo; echo


# Set project name
cd "$PROJECTS_DIR"

if [ -d "$PROJECT_NAME" ]; then

	echo-red "Error: Project name already exists"; echo-white

	exit 1

fi

mkdir $PROJECT_NAME

cd $PROJECT_NAME

if [ "$PROJECT_TYPE" = "laravel" ]; then
    echo; echo-cyan "Creating Laravel project..."
    
    git init
    git remote add laravel https://github.com/laravel/laravel.git
    git fetch laravel $CUR_LARAVEL_BRANCH
    git merge laravel/$CUR_LARAVEL_BRANCH
    
    echo-green "Laravel project structure created!"

elif [ "$PROJECT_TYPE" = "wordpress" ]; then
    echo; echo-cyan "Downloading WordPress..."
    
    if [ "$WP_VERSION" = "latest" ]; then
        curl -O https://wordpress.org/latest.tar.gz
        tar -xzf latest.tar.gz --strip-components=1
        rm latest.tar.gz
    else
        curl -O https://wordpress.org/wordpress-${WP_VERSION}.tar.gz
        tar -xzf wordpress-${WP_VERSION}.tar.gz --strip-components=1
        rm wordpress-${WP_VERSION}.tar.gz
    fi
    
    # Initialize git for WordPress
    git init
    
    # Create basic .gitignore for WordPress
    cat > .gitignore << EOF
# WordPress core files
wp-config.php
wp-content/uploads/
wp-content/cache/
wp-content/backup-db/
wp-content/advanced-cache.php
wp-content/wp-cache-config.php
wp-content/plugins/hello.php
wp-content/plugins/akismet/
wp-content/upgrade/
wp-content/debug.log

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF
    
    git add .
    git commit -m "Initial WordPress setup"
    
    echo-green "WordPress downloaded and initialized!"
fi


# Push to Github
REPO_NAME=$PROJECT_NAME

if ! [ -z "$ORGANIZATION" ]; then REPO_NAME="$ORGANIZATION/$PROJECT_NAME"; fi

echo; echo-cyan "Creating GitHub repository..."
gh repo create $REPO_NAME --private --source=. --push

cd ../..


# Setup project
source "$DEV_DIR/scripts/setup_project.sh" $PROJECT_NAME

cd $ORIG_DIR