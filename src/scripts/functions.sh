#!/bin/bash
# Podium - Internal Functions
# This file provides functions needed by Podium scripts without polluting user's shell

# Get the projects directory (configurable)
get_projects_dir() {
    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local podium_root="$(dirname "$script_dir")"
    
    # First check docker-stack/.env file (preferred method)
    if [ -f "$podium_root/docker-stack/.env" ]; then
        PROJECTS_DIR=$(grep "^PROJECTS_DIR=" "$podium_root/docker-stack/.env" 2>/dev/null | cut -d'=' -f2)
        if [ -n "$PROJECTS_DIR" ]; then
            # Expand tilde to home directory
            PROJECTS_DIR="${PROJECTS_DIR/#\~/$HOME}"
            echo "$PROJECTS_DIR"
            return
        fi
    fi
    
    # Fallback to legacy ~/.podium/config for backward compatibility
    if [ -f ~/.podium/config ]; then
        PROJECTS_DIR=$(grep "^PROJECTS_DIR=" ~/.podium/config | cut -d'=' -f2)
        if [ -n "$PROJECTS_DIR" ]; then
            echo "$PROJECTS_DIR"
            return
        fi
    fi
    
    # Default to ~/podium-projects
    echo "$HOME/podium-projects"
}

# Initialize projects directory if it doesn't exist
init_projects_dir() {
    local projects_dir="$(get_projects_dir)"
    if [ ! -d "$projects_dir" ]; then
        echo-cyan "Creating projects directory: $projects_dir"
        mkdir -p "$projects_dir"
    fi
}

# Color output functions
echo-red() { tput setaf 1 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-green() { tput setaf 2 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-yellow() { tput setaf 3 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-blue() { tput setaf 4 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-magenta() { tput setaf 5 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-cyan() { tput setaf 6 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-white() { tput setaf 7 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }

# Docker aliases used by scripts (keep these for internal script usage)
dockerup() { docker compose up -d "$@"; }
dockerdown() { docker compose down "$@"; }
dockerexec() { docker container exec -it "$@"; }
dockerls() { docker container ls "$@"; }
dockerrm() { docker container rm "$@"; }

# Project-specific Docker commands (run inside project containers)
composer-docker() { 
    local project_name="$(basename "$(pwd)")"
    if [ -t 0 ]; then
        # Interactive mode (TTY available)
        docker container exec -it --user "$(id -u):$(id -g)" --workdir /usr/share/nginx/html "$project_name" composer "$@"
    else
        # Non-interactive mode (no TTY, for scripts)
        docker container exec --user "$(id -u):$(id -g)" --workdir /usr/share/nginx/html "$project_name" composer "$@"
    fi
}
art-docker() { 
    local project_name="$(basename "$(pwd)")"
    if [ -t 0 ]; then
        # Interactive mode (TTY available)
        docker container exec -it --user "$(id -u):$(id -g)" --workdir /usr/share/nginx/html "$project_name" php artisan "$@"
    else
        # Non-interactive mode (no TTY, for scripts)
        docker container exec --user "$(id -u):$(id -g)" --workdir /usr/share/nginx/html "$project_name" php artisan "$@"
    fi
}

# Check if services are running
check-mariadb() { [ "$(docker ps -q -f name=mariadb)" ] && return 0 || return 1; }
check-phpmyadmin() { [ "$(docker ps -q -f name=phpmyadmin)" ] && return 0 || return 1; }

# Utility functions
divider() { echo; echo-white '==============================='; echo; }
whatismyip() { dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null || echo "Unable to get IP"; }

# Cross-platform sed function
podium-sed() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Cross-platform sudo sed function
sudo-podium-sed() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo sed -i '' "$@"
    else
        sudo sed -i "$@"
    fi
}

# Safe sudo function (doesn't override user's sudo)
podium-sudo() {
    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        "$@"
    fi
}
