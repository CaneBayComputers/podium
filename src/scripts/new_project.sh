#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd "$(dirname "$(realpath "$0")")"

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

# Get projects directory
PROJECTS_DIR="$(get_projects_dir)"

# Main
source "$DEV_DIR/scripts/pre_check.sh"


# Function to display usage
usage() {
    echo "Usage: $0 <project_name> [organization] [version] [options]"
    echo "Creates a new Laravel or WordPress project"
    echo ""
    echo "Arguments:"
    echo "  project_name    Name of the project to create"
    echo "  organization    GitHub organization (optional)"
    echo "  version         Framework version (optional)"
    echo ""
    echo "Options:"
    echo "  --framework TYPE        Framework type: laravel, wordpress"
    echo "  --version VERSION       Specific version (e.g., 12.x, 11.x, 10.x, latest)"
    echo "  --database TYPE         Database type: mysql, postgres, mongo"
    echo "  --github                Create GitHub repository automatically"
    echo "  --no-github             Skip GitHub repository creation"
    echo ""
    echo "Examples:"
    echo "  $0 my-app --framework laravel --version 11.x --database postgres --github"
    echo "  $0 my-blog --framework wordpress --database mysql --no-github"
    exit 1
}

# Initialize variables
PROJECT_NAME=""
ORGANIZATION=""
VERSION=""
FRAMEWORK=""
DATABASE=""
CREATE_GITHUB=""
INTERACTIVE_MODE=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --framework)
            FRAMEWORK="$2"
            INTERACTIVE_MODE=false
            shift 2
            ;;
        --version)
            VERSION="$2"
            INTERACTIVE_MODE=false
            shift 2
            ;;
        --database)
            DATABASE="$2"
            INTERACTIVE_MODE=false
            shift 2
            ;;
        --github)
            CREATE_GITHUB="yes"
            INTERACTIVE_MODE=false
            shift
            ;;
        --no-github)
            CREATE_GITHUB="no"
            INTERACTIVE_MODE=false
            shift
            ;;
        --help)
            usage
            ;;
        -*)
            echo-red "Unknown option: $1"
            usage
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            elif [ -z "$ORGANIZATION" ]; then
                ORGANIZATION="$1"
            elif [ -z "$VERSION" ]; then
                VERSION="$1"
            else
                echo-red "Too many arguments"
                usage
            fi
            shift
            ;;
    esac
done

# Interactive mode if no project name provided
if [ -z "$PROJECT_NAME" ]; then
    echo; echo-cyan "🚀 Create a New Podium Project"
    echo
    echo-white -n "Enter project name: "
    read PROJECT_NAME
    
    if [ -z "$PROJECT_NAME" ]; then
        echo-red "Project name cannot be empty!"
        exit 1
    fi
    
    echo-white -n "Enter organization name (optional): "
    read ORGANIZATION
fi


# Convert to lowercase, replace spaces with dashes, and remove non-alphanumeric characters
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-_')


# Project type selection
# Framework selection
if [ -z "$FRAMEWORK" ]; then
    echo; echo-cyan "What type of project would you like to create?"
    echo-white "1) Laravel (PHP Framework)"
    echo-white "2) WordPress (CMS)"
    echo; echo-yellow -n "Enter your choice (1-2): "
    read PROJECT_TYPE_CHOICE
    
    case $PROJECT_TYPE_CHOICE in
        1)
            PROJECT_TYPE="laravel"
            ;;
        2)
            PROJECT_TYPE="wordpress"
            ;;
        *)
            echo-red "Invalid choice. Exiting..."
            exit 1
            ;;
    esac
else
    PROJECT_TYPE="$FRAMEWORK"
fi

case $PROJECT_TYPE in
    laravel)
        echo; echo-cyan "Laravel project selected!"
        
        # Laravel version selection
        if [ -z "$VERSION" ]; then
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
        else
            CUR_LARAVEL_BRANCH="$VERSION"
            echo; echo-cyan "Laravel $VERSION selected!"
        fi
        ;;
    wordpress)
        echo; echo-cyan "WordPress project selected!"
        
        # WordPress version selection
        if [ -z "$VERSION" ]; then
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
        else
            WP_VERSION="$VERSION"
            echo; echo-cyan "WordPress $VERSION selected!"
        fi
        ;;
    *)
        echo-red "Unknown framework '$FRAMEWORK'. Exiting..."
        exit 1
        ;;
esac

# Database selection
if [ -z "$DATABASE" ]; then
    echo; echo-cyan "Which database would you like to use?"
    echo-white "1) MySQL/MariaDB (Default)"
    echo-white "2) PostgreSQL"
    echo-white "3) MongoDB"
    echo; echo-yellow -n "Enter your choice (1-3): "
    read DB_CHOICE
    
    case $DB_CHOICE in
        1)
            DATABASE_TYPE="mysql"
            echo-green "MySQL/MariaDB selected!"
            ;;
        2)
            DATABASE_TYPE="postgres"
            echo-green "PostgreSQL selected!"
            ;;
        3)
            DATABASE_TYPE="mongo"
            echo-green "MongoDB selected!"
            ;;
        *)
            echo-yellow "Invalid choice. Defaulting to MySQL/MariaDB"
            DATABASE_TYPE="mysql"
            ;;
    esac
else
    case "$DATABASE" in
        mysql|mariadb)
            DATABASE_TYPE="mysql"
            echo; echo-cyan "MySQL/MariaDB selected!"
            ;;
        postgres|postgresql)
            DATABASE_TYPE="postgres"
            echo; echo-cyan "PostgreSQL selected!"
            ;;
        mongo|mongodb)
            DATABASE_TYPE="mongo"
            echo; echo-cyan "MongoDB selected!"
            ;;
        *)
            echo-yellow "Unknown database '$DATABASE'. Defaulting to MySQL/MariaDB"
            DATABASE_TYPE="mysql"
            ;;
    esac
fi

echo; echo


# Set project name
cd "$PROJECTS_DIR"

if [ -d "$PROJECT_NAME" ]; then

	echo-red "Error: Project name already exists"; echo-white

	exit 1

fi

mkdir "$PROJECT_NAME"

cd "$PROJECT_NAME"

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


# GitHub repository creation
if [ -z "$CREATE_GITHUB" ]; then
    echo; echo-cyan "Would you like to create a GitHub repository?"
    echo-white "1) Yes, create GitHub repository"
    echo-white "2) No, skip GitHub repository"
    echo; echo-yellow -n "Enter your choice (1-2): "
    read GITHUB_CHOICE
    
    case $GITHUB_CHOICE in
        1)
            CREATE_GITHUB="yes"
            ;;
        2)
            CREATE_GITHUB="no"
            ;;
        *)
            echo-yellow "Invalid choice. Skipping GitHub repository creation"
            CREATE_GITHUB="no"
            ;;
    esac
fi

if [ "$CREATE_GITHUB" = "yes" ]; then
    REPO_NAME=$PROJECT_NAME
    if ! [ -z "$ORGANIZATION" ]; then 
        REPO_NAME="$ORGANIZATION/$PROJECT_NAME"
    fi

    echo; echo-cyan "Creating GitHub repository..."
    if gh repo create $REPO_NAME --private --source=. --push; then
        echo-green "GitHub repository created successfully!"
    else
        echo-yellow "GitHub repository creation failed, but project setup will continue."
    fi
else
    echo; echo-yellow "Skipping GitHub repository creation."
fi

cd ../..


# Setup project
source "$DEV_DIR/scripts/setup_project.sh" $PROJECT_NAME $DATABASE_TYPE

# JSON output for project creation
if [[ "$JSON_OUTPUT" == "1" ]]; then
    echo "{\"action\": \"new_project\", \"project_name\": \"$PROJECT_NAME\", \"framework\": \"$PROJECT_TYPE\", \"database\": \"$DATABASE_TYPE\", \"status\": \"success\"}"
fi

cd "$ORIG_DIR"