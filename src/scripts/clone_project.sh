#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh


# Function to display usage
usage() {

    echo "Usage: $0 <repository> [project_name]"
    
    exit 1
}


# Check if repository argument is provided
if [ -z "$1" ]; then

    echo-red "Error: Repository is required."; echo-white

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
echo

echo "Repository: $REPOSITORY"

echo "Project Name: $PROJECT_NAME"


# Convert to lowercase, replace spaces with dashes, and remove non-alphanumeric characters
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-_')


# Clone repository
echo

cd projects

if [ -d "$PROJECT_NAME" ]; then

    echo-red "Error: Project name already exists."; echo-white

    exit 1

fi

git clone $REPOSITORY $PROJECT_NAME

echo

cd ..


# Setup project
source "$DEV_DIR/scripts/setup_project.sh" $PROJECT_NAME

cd $ORIG_DIR