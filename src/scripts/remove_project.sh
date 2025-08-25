#!/bin/bash

set -e

# Set up directories and aliases
ORIG_DIR=$(pwd)
cd "$(dirname "$(realpath "$0")")"
cd ..
DEV_DIR=$(pwd)
source scripts/functions.sh

echo; echo

# Usage function to explain the script
usage() {
    echo "Usage: $0 <project_name>"
    exit 1
}

# Check if project name is provided
if [ -z "$1" ]; then
    usage
fi

PROJECT_NAME=$1
PROJECT_DIR="$(get_projects_dir)/$PROJECT_NAME"
HOSTS_FILE="/etc/hosts"

# Confirm with the user before proceeding
echo-cyan "This will remove the project '$PROJECT_NAME' and associated settings."
echo-cyan "Project files will be moved to trash (recoverable)."
echo-white
read -p "Are you sure? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# 1. Run shutdown.sh to stop the project and remove iptables rules
echo
echo-cyan "Shutting down project '$PROJECT_NAME'..."
echo-white
"$DEV_DIR/scripts/shutdown.sh" "$PROJECT_NAME"

# 2. Move Project Directory to Trash
echo-cyan "Moving project directory to trash..."
echo-white
if [ -d "$PROJECT_DIR" ]; then
    # Function to move project to trash safely
    if command -v trash-put &> /dev/null; then
        trash-put "$PROJECT_DIR"
        echo-green "Project directory moved to trash (can be recovered)."
    elif command -v trash &> /dev/null; then
        # Alternative trash command (some systems)
        trash "$PROJECT_DIR"
        echo-green "Project directory moved to trash (can be recovered)."
    else
        # Fallback: ask user if they want permanent deletion
        echo-yellow "Warning: trash-cli not installed. This will PERMANENTLY delete the project!"
        echo-white
        read -p "Continue with permanent deletion? (y/n): " PERMANENT_DELETE
        if [[ "$PERMANENT_DELETE" == "y" ]]; then
            rm -rf "$PROJECT_DIR"
            echo-red "Project directory permanently deleted."
        else
            echo-yellow "Project directory removal cancelled."
            echo-white "Install trash-cli for safer project removal:"
            echo-white "  Linux: sudo apt-get install trash-cli"
            echo-white "  macOS: brew install trash-cli"
            cd "$ORIG_DIR"
            exit 0
        fi
    fi
    echo-white
else
    echo-yellow "Project directory not found. Skipping directory removal."
    echo-white
fi

# 3. Remove Hosts File Entry
echo-cyan "Removing hosts file entry for the project..."
echo-white
if grep -q " $PROJECT_NAME\$" "$HOSTS_FILE"; then
    sudo sed -i "/ $PROJECT_NAME\$/d" "$HOSTS_FILE"
    echo-green "Hosts file entry removed."
    echo-white
else
    echo-yellow "Hosts file entry not found. Skipping hosts file update."
    echo-white
fi

# 4. Delete Docker Container
echo-cyan "Attempting to delete Docker container for '$PROJECT_NAME'..."
echo-white
if docker rm "$PROJECT_NAME" --force >/dev/null 2>&1; then
    echo-green "Docker container for '$PROJECT_NAME' removed."
    echo-white
else
    echo-yellow "Docker container for '$PROJECT_NAME' not found or already removed."
    echo-white
fi

# 5. Ask if user wants to delete the associated database
DB_NAME=$(echo "$PROJECT_NAME" | sed 's/-/_/g')
echo-cyan "Would you like to delete the associated database '$DB_NAME'? This cannot be undone!"
echo-white
read -p "Delete database? (y/n): " DELETE_DB_CONFIRM
if [[ "$DELETE_DB_CONFIRM" == "y" ]]; then

    # Start services including mariadb
    "$DEV_DIR/scripts/start_services.sh"

    # Check if db exists
    echo-cyan "Checking if database '$DB_NAME' exists..."
    echo-white
    DB_EXISTS=$(mysql -h mariadb -u root -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" || true)

    if [ -n "$DB_EXISTS" ]; then
        # If the database exists, proceed with deletion
        echo-cyan "Deleting database '$DB_NAME'..."
        echo-white
        mysql -h mariadb -u root -e "DROP DATABASE \`$DB_NAME\`;" && echo-green "Database '$DB_NAME' deleted."
        echo-white
    else
        # If the database does not exist, display a warning message
        echo-yellow "Database '$DB_NAME' not found. Skipping deletion."
        echo-white
    fi

else
    echo-yellow "Database deletion skipped."
    echo-white
fi

# Return to original directory
cd "$ORIG_DIR"

echo-green "Project '$PROJECT_NAME' and associated settings have been removed."
echo-white
