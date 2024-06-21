#!/bin/bash

set -e

shopt -s expand_aliases

ORIG_DIR=$(pwd)

cd "$(dirname "$0")"

DEV_DIR=$(pwd)

source .bash_aliases

# Prompt the user for input
echo; echo

read -p "Enter name of new project: " PROJECT_NAME

# Convert to lowercase, replace spaces with dashes, and remove non-alphanumeric characters
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

echo; echo-blue "PHP 7 includes Laravel 7
PHP 8 includes Laravel 10"

echo-white

read -p "Which PHP version (7/8): " VER

# Check if the input is either "7" or "8"
if [[ "$VER" != "7" && "$VER" != "8" ]]; then

  echo "Error: You must enter either '7' or '8'."

  exit 1

fi

VER=cbc-laravel-php$VER

echo; echo

cd projects

mkdir $PROJECT_NAME

cd $PROJECT_NAME

git init

git remote add $VER https://github.com/CaneBayComputers/$VER.git

git fetch $VER

git pull $VER master

echo; echo

cd $ORIG_DIR