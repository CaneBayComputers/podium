#!/bin/bash
# Laravel Podium - Internal Functions
# This file provides functions needed by Podium scripts without polluting user's shell

# Color output functions
echo-red() { tput setaf 1 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-green() { tput setaf 2 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-yellow() { tput setaf 3 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-blue() { tput setaf 4 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-magenta() { tput setaf 5 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-cyan() { tput setaf 6 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }
echo-white() { tput setaf 7 2>/dev/null; echo "$@"; tput sgr0 2>/dev/null; }

# Docker helper functions
podium-docker-up() { docker compose up -d "$@"; }
podium-docker-down() { docker compose down "$@"; }
podium-docker-exec() { docker container exec -it "$@"; }

# Docker aliases used by scripts
dockerup() { docker compose up -d "$@"; }
dockerdown() { docker compose down "$@"; }
dockerexec() { docker container exec -it "$@"; }
dockerls() { docker container ls "$@"; }
dockerrm() { docker container rm "$@"; }

# Essential containerized development tools
podium-composer() { docker container exec -it --user $(id -u):$(id -g) $(basename $(pwd)) composer -d /usr/share/nginx/html "$@"; }
podium-artisan() { docker container exec -it --user $(id -u):$(id -g) $(basename $(pwd)) php /usr/share/nginx/html/artisan "$@"; }
podium-wp() { docker container exec -it --user $(id -u):$(id -g) $(basename $(pwd)) wp "$@"; }
podium-php() { docker container exec -it --user $(id -u):$(id -g) $(basename $(pwd)) php "$@"; }

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

# Safe sudo function (doesn't override user's sudo)
podium-sudo() {
    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        "$@"
    fi
}
