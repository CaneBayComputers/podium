#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source extras/.bash_aliases


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


# Clone repository
echo; echo

cd projects

git clone $REPOSITORY $PROJECT_NAME

cd ..


# Setup project
