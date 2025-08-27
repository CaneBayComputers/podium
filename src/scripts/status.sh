#!/bin/bash

set -e


cd "$(dirname "$(realpath "$0")")"

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh


# Variables
PROJECT_NAME=""

if [[ -n "$1" ]]; then

  PROJECT_NAME="$1"

fi

RUNNING_SITES=""

RUNNING_INTERNAL=""

RUNNING_EXTERNAL=""

LAN_IP=$(hostname -I | awk '{print $1}')

# Docker handles port mapping automatically

HOSTS=$(cat /etc/hosts)


# Functions
get_service_status() {
    local service_name="$1"
    if docker ps --format "table {{.Names}}" | grep -q "$service_name"; then
        echo "running"
    else
        echo "stopped"
    fi
}

get_project_status() {
    local proj_name="$1"
    local project_data="{}"
    
    # Project folder check
    if [ -d "$proj_name" ]; then
        project_data=$(echo "$project_data" | jq --arg name "$proj_name" '. + {name: $name, folder_exists: true}')
    else
        project_data=$(echo "$project_data" | jq --arg name "$proj_name" '. + {name: $name, folder_exists: false}')
    fi
    
    # Host entry check
    if HOST_ENTRY=$(printf "%s\n" "$HOSTS" | grep " $proj_name$"); then
        EXT_PORT=$(echo $HOST_ENTRY | cut -d'.' -f 4 | cut -d' ' -f 1)
        project_data=$(echo "$project_data" | jq --arg port "$EXT_PORT" '. + {host_entry: true, external_port: $port}')
    else
        project_data=$(echo "$project_data" | jq '. + {host_entry: false, external_port: null}')
    fi
    
    # Docker status check
    if [ "$(docker ps -q -f name=$proj_name)" ]; then
        project_data=$(echo "$project_data" | jq '. + {docker_running: true}')
        
        # Port mapping check (only if running)
        if docker port "$proj_name" 80/tcp > /dev/null 2>&1; then
            project_data=$(echo "$project_data" | jq '. + {port_mapped: true}')
        else
            project_data=$(echo "$project_data" | jq '. + {port_mapped: false}')
        fi
    else
        project_data=$(echo "$project_data" | jq '. + {docker_running: false, port_mapped: false}')
    fi
    
    # URLs
    if [ -n "$HOST_ENTRY" ]; then
        project_data=$(echo "$project_data" | jq --arg local "http://$proj_name" --arg lan "http://$LAN_IP:$EXT_PORT" '. + {local_url: $local, lan_url: $lan}')
    else
        project_data=$(echo "$project_data" | jq '. + {local_url: null, lan_url: null}')
    fi
    
    echo "$project_data"
}

project_status() {
  PROJ_NAME=$1

  if [[ "$JSON_OUTPUT" == "1" ]]; then
    # JSON output is handled in main section
    return 0
  fi

  echo -n PROJECT:
  echo-yellow " $PROJ_NAME"

  echo-white -n PROJECT FOLDER:
  if ! [ -d "$PROJ_NAME" ]; then
    echo-red " NOT FOUND"
    echo-white -n SUGGESTION:; echo-yellow " Check spelling or clone repo"
    return 1
  else
    echo-green " FOUND"
  fi

  echo-white -n HOST ENTRY: 
  if ! HOST_ENTRY=$(printf "%s\n" "$HOSTS" | grep " $PROJ_NAME$"); then
    echo-red " NOT FOUND"
    echo-white -n SUGGESTION:; echo-yellow " Run: setup_project.sh $PROJ_NAME"
    return 1
  else
    echo-green " FOUND"
  fi

  echo-white -n DOCKER STATUS:
  if ! [ "$(docker ps -q -f name=$PROJ_NAME)" ]; then
    echo-red " NOT RUNNING"
    echo-white -n SUGGESTION:; echo-yellow " Run startup.sh script"
    return 1
  else
    echo-green " RUNNING"
  fi

  echo-white -n DOCKER PORT MAPPING:
  EXT_PORT=$(echo $HOST_ENTRY | cut -d'.' -f 4 | cut -d' ' -f 1)
  # Check if Docker container has port mapping
  if ! docker port "$PROJ_NAME" 80/tcp > /dev/null 2>&1; then
    echo-red " NOT MAPPED"
    echo-white -n SUGGESTION:; echo-yellow " Run shutdown.sh then startup.sh script"
    return 1
  else
    echo-green " MAPPED"
  fi

  echo-white -n LOCAL ACCESS:; echo-yellow " http://$PROJ_NAME"
  echo-white -n LAN ACCESS:; echo-yellow " http://$LAN_IP:$EXT_PORT"
}


# Main

# Do not run as root
if [[ "$(whoami)" == "root" ]]; then

  echo-red "Do NOT run with sudo!"; echo-white; echo

  exit 1

fi


# Check if this environment is installed
if ! [ -f docker-stack/.env ]; then

  echo-return; echo-red 'Development environment has not been configured!'; echo-white

  echo 'Run: podium config'

  exit 1

fi


# Start CBC stack
if ! check-mariadb; then

  echo-return; echo-red 'Development environment is not started!'; echo-white

  echo 'Run startup.sh'

  exit 1

fi


# Handle JSON output
if [[ "$JSON_OUTPUT" == "1" ]]; then
    # Collect all data first
    JSON_DATA='{"shared_services": {}, "projects": []}'
    
    # Get shared services status
    JSON_DATA=$(echo "$JSON_DATA" | jq --arg status "$(get_service_status 'mariadb')" '.shared_services.mariadb = {name: "MariaDB", status: $status}')
    JSON_DATA=$(echo "$JSON_DATA" | jq --arg status "$(get_service_status 'phpmyadmin')" '.shared_services.phpmyadmin = {name: "phpMyAdmin", status: $status}')
    JSON_DATA=$(echo "$JSON_DATA" | jq --arg status "$(get_service_status 'redis')" '.shared_services.redis = {name: "Redis", status: $status}')
    JSON_DATA=$(echo "$JSON_DATA" | jq --arg status "$(get_service_status 'memcached')" '.shared_services.memcached = {name: "Memcached", status: $status}')
    
    # Get projects directory and iterate through projects
    PROJECTS_DIR=$(get_projects_dir)
    cd "$PROJECTS_DIR"
    
    if ! [ -z "$PROJECT_NAME" ]; then
        # Single project requested
        if [ -d "$PROJECT_NAME" ]; then
            PROJECT_JSON=$(get_project_status "$PROJECT_NAME")
            JSON_DATA=$(echo "$JSON_DATA" | jq --argjson project "$PROJECT_JSON" '.projects += [$project]')
        fi
    else
        # All projects
        for item in *; do
            if [ -d "$item" ] && [ "$item" != "." ] && [ "$item" != ".." ]; then
                PROJECT_JSON=$(get_project_status "$item")
                JSON_DATA=$(echo "$JSON_DATA" | jq --argjson project "$PROJECT_JSON" '.projects += [$project]')
            fi
        done
    fi
    
    # Output JSON (unless suppressed for intermediate calls)
    if [[ "$SUPPRESS_INTERMEDIATE_JSON" != "1" ]]; then
        echo "$JSON_DATA"
    fi
    exit 0
fi

# Traditional text output
echo-cyan "SHARED SERVICES STATUS:"
echo

# Check MariaDB
echo-white -n "MariaDB: "
if docker ps --format "table {{.Names}}" | grep -q "mariadb"; then
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-green "✅ RUNNING"
    else
        echo-green "RUNNING"
    fi
else
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-red "❌ STOPPED"
    else
        echo-red "STOPPED"
    fi
fi

# Check phpMyAdmin
echo-white -n "phpMyAdmin: "
if docker ps --format "table {{.Names}}" | grep -q "phpmyadmin"; then
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-green "✅ RUNNING"
    else
        echo-green "RUNNING"
    fi
else
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-red "❌ STOPPED"
    else
        echo-red "STOPPED"
    fi
fi

# Check Redis
echo-white -n "Redis: "
if docker ps --format "table {{.Names}}" | grep -q "redis"; then
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-green "✅ RUNNING"
    else
        echo-green "RUNNING"
    fi
else
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-red "❌ STOPPED"
    else
        echo-red "STOPPED"
    fi
fi

# Check Memcached
echo-white -n "Memcached: "
if docker ps --format "table {{.Names}}" | grep -q "memcached"; then
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-green "✅ RUNNING"
    else
        echo-green "RUNNING"
    fi
else
    if [[ "$NO_COLOR" != "1" ]]; then
        echo-red "❌ STOPPED"
    else
        echo-red "STOPPED"
    fi
fi

divider

# Iterate through projects folder using get_projects_dir function
PROJECTS_DIR=$(get_projects_dir)
cd "$PROJECTS_DIR"

if ! [ -z "$PROJECT_NAME" ]; then
    if project_status $PROJECT_NAME; then true; fi
    divider
else
    # Check if there are any actual project directories (not just files)
    PROJECT_COUNT=0
    for item in *; do
        if [ -d "$item" ] && [ "$item" != "." ] && [ "$item" != ".." ]; then
            PROJECT_COUNT=$((PROJECT_COUNT + 1))
        fi
    done
    
    if [ $PROJECT_COUNT -eq 0 ]; then
        echo-cyan "PROJECTS STATUS:"
        echo
        echo-yellow "No projects found in $(pwd)"
        echo-white "Create your first project with: podium new"
        divider
    else
        echo-cyan "PROJECTS STATUS:"
        echo
        for PROJECT_NAME in *; do
            if [ -d "$PROJECT_NAME" ] && [ "$PROJECT_NAME" != "." ] && [ "$PROJECT_NAME" != ".." ]; then
                if project_status $PROJECT_NAME; then true; fi
                divider
            fi
        done
    fi
fi

echo-return; echo-return

