# 🚀 Podium: The Complete PHP Development Platform

**One command. Complete development environment. Any PHP project.**

Podium is a comprehensive Docker-based development platform that creates professional PHP development environments with complete automation. **Manage multiple projects across different frameworks** - Laravel, WordPress, and generic PHP - all running simultaneously with shared services. Perfect for teams, agencies, and developers who need **easy project access for demos and collaboration**, including LAN access so your boss Frank can check your work from any device on the network.

## ✨ What Makes Podium Special

### 🎯 **Complete Turnkey Experience**
- **One installer** sets up your entire development environment
- **One command** creates ready-to-code projects  
- **Zero manual configuration** - everything works out of the box
- **Cross-platform** - Linux, macOS, Windows (WSL2)

### 🏗️ **Multi-Project Architecture**
- **Run multiple projects simultaneously** - Laravel, WordPress, PHP all at once
- **Cross-framework compatibility** - Mix and match project types
- **Shared services** (MySQL, Redis, phpMyAdmin) serve all projects efficiently
- **Individual project isolation** with unique ports and containers

### 🌐 **Easy Access for Everyone**
- **Local development**: `http://project-name` for your work
- **LAN access**: `http://your-ip:port` for team demos and testing
- **Mobile testing**: Access projects from phones and tablets on your network
- **Client presentations**: Show work to stakeholders from any device

## 🎬 Quick Start

### Install Podium
```bash
git clone https://github.com/CaneBayComputers/podium-cli.git
cd podium-cli
./scripts/install.sh
```

### Create Your First Project
```bash
./scripts/new_project.sh my-awesome-app
```

### Start Coding! 
```bash
# Your project is ready at:
http://my-awesome-app
```

**You now have a fully configured development environment with:**
- ✅ Running Laravel/WordPress application
- ✅ Database configured and connected
- ✅ Redis caching ready
- ✅ Email system configured
- ✅ phpMyAdmin for database management
- ✅ Professional development tools

## 🛠️ Core Commands

### Project Management

#### Creating New Projects
```bash
./scripts/new_project.sh <project_name> [organization]
```
- **`<project_name>`**: The name of your new project (required)
- **`[organization]`**: Optional GitHub organization for repository creation

Creates a new Laravel or WordPress project with:
- Interactive framework selection (Laravel/WordPress)
- Version selection (Laravel 12.x, 11.x, 10.x or WordPress latest/6.4/6.3)
- Automatic GitHub repository creation
- Complete environment configuration
- Database setup and connection

#### Cloning Existing Projects
```bash
./scripts/clone_project.sh <repository> [project_name]
```
- **`<repository>`**: The URL of the repository to clone (required)
- **`[project_name]`**: Optional custom name for the cloned project

Clones an existing project and automatically:
- Downloads the repository
- Detects project type (Laravel/WordPress/PHP)
- Configures environment files
- Sets up database connections
- Starts the development environment

#### Setting Up Downloaded Projects
```bash
./scripts/setup_project.sh <project_name>
```
- **`<project_name>`**: The name of the project directory (required)

Configures an already downloaded project by:
- Detecting PHP version requirements from composer.json
- Creating Docker Compose configuration
- Setting up environment files (.env for Laravel, wp-config.php for WordPress)
- Creating and configuring project database
- Running migrations and setup commands
- Starting the project container

#### Removing Projects Safely
```bash
./scripts/remove_project.sh <project_name>
```
- **`<project_name>`**: The name of the project to remove (required)

Safely removes a project by:
- Moving project directory to system trash (recoverable)
- Stopping and removing Docker containers
- Cleaning up database (with confirmation)
- Removing hosts file entries
- Cleaning up all project-related configurations

### Service Management

#### Starting Projects
```bash
# Start all projects
./scripts/startup.sh

# Start specific project
./scripts/startup.sh <project_name>
```
- Starts Docker containers for projects
- Configures networking and port mapping
- Makes projects accessible via browser

#### Stopping Projects
```bash
# Stop all projects
./scripts/shutdown.sh

# Stop specific project  
./scripts/shutdown.sh <project_name>
```
- Gracefully stops Docker containers
- Cleans up networking configurations
- Preserves project data and configurations

#### Checking Project Status
```bash
# Check all projects
./scripts/status.sh

# Check specific project
./scripts/status.sh <project_name>
```
- Displays project status and health
- Shows access URLs (local and LAN)
- Provides troubleshooting suggestions if issues detected

## 🔧 Essential Development Tools

### Why Containerized Tools Matter

Podium uses **containerized development tools** that run inside Docker containers instead of on your host system. This is **crucial for professional PHP development** because:

#### **🎯 Consistent Environment**
- **Same PHP version** across all team members
- **Identical extensions** and configurations  
- **No "works on my machine" problems**
- **Perfect for team collaboration**

#### **🔄 Proper Dependencies**
- **Composer runs with correct PHP version** - ensures packages install correctly
- **WP-CLI uses container's WordPress environment** - commands work reliably  
- **Artisan uses container's Laravel setup** - migrations and commands execute properly
- **No host system conflicts** - your system PHP doesn't interfere

#### **🚀 Professional Workflow Benefits**
- **Switch between PHP versions** per project without system changes
- **Clean host system** - no PHP version conflicts or extension issues
- **Portable environments** - same setup works on any developer's machine
- **Production parity** - development matches server environment

### Core Development Commands
```bash
# Composer (runs inside container with correct PHP environment)
composer-docker install
composer-docker require laravel/sanctum
composer-docker update

# Laravel Artisan (runs inside container)
art-docker migrate
art-docker make:controller UserController
art-docker tinker
art-docker queue:work

# WordPress CLI (runs inside container)  
wp-docker plugin list
wp-docker user create john john@example.com --role=administrator
wp-docker db export backup.sql

# PHP (runs inside container)
php-docker -v
php-docker script.php
```

### Enhanced Laravel Workflows
```bash
# Database refresh with seeding
art-docker-db-refresh

# Clear all Laravel caches
art-docker-refresh
```

### Service Management
```bash
# Redis CLI access
redis-docker
redis-flushall

# Direct container access
dockerexec my-project bash
dockerexec-root my-project bash
```

### Container Execution Helpers
```bash
# Execute commands in project container
dockerexec my-project bash

# Execute as root (for system tasks)
dockerexec-root my-project apt-get install something

# Execute as developer (for application tasks)
dockerexec-developer my-project composer install
```

## 🌐 Multi-Project Development

Podium excels at **managing multiple projects simultaneously across different frameworks**:

```bash
# Create multiple projects of different types
./scripts/new_project.sh client-website    # WordPress
./scripts/new_project.sh api-backend       # Laravel  
./scripts/new_project.sh legacy-app        # PHP

# All running simultaneously:
# http://client-website     (WordPress)
# http://api-backend        (Laravel)  
# http://legacy-app         (PHP)
```

**Shared services** (MySQL, Redis, phpMyAdmin) serve all projects efficiently while maintaining complete isolation between projects.

## 🔍 Project Status and Access

### Status Display Example:
```text
PROJECT: my-laravel-app
PROJECT FOLDER: ✅ FOUND
HOST ENTRY: ✅ FOUND  
DOCKER STATUS: ✅ RUNNING
DOCKER PORT MAPPING: ✅ MAPPED
LOCAL ACCESS: http://my-laravel-app
LAN ACCESS: http://192.168.1.100:8123
```

### Access Your Projects:
- **Local Development**: `http://project-name` 
- **LAN Testing**: `http://YOUR-IP:PORT` - Perfect for showing Frank your progress from his phone or computer
- **Database Management**: `http://podium-phpmyadmin`

## 🏗️ Architecture Overview

### Shared Services (One Stack for All Projects)
- **MariaDB**: Database server for all projects
- **Redis**: Caching and sessions
- **phpMyAdmin**: Database management interface  
- **Memcached**: Additional caching layer
- **Exim4**: Email delivery system

### Per-Project Containers
Each project gets its own optimized container:
- **Custom Docker Image**: Pre-built with PHP, Nginx, Composer, WP-CLI
- **Automatic Configuration**: Ready-to-use environment
- **Port Mapping**: Unique port for LAN access
- **Volume Mounting**: Live code editing

## 🌍 Cross-Platform Support

### Linux (Ubuntu/Debian)
```bash
./scripts/install.sh  # Installs Docker, Git, Node.js, development tools
```

### macOS
```bash
./scripts/install.sh  # Installs via Homebrew: Docker Desktop, Git, development tools
```

### Windows
```bash
# Via WSL2 Ubuntu
./scripts/install.sh  # Same as Linux installation
```

## 📁 Project Structure

```
podium-cli/
├── docker-stack/           # Shared services (MySQL, Redis, etc.)
│   ├── docker-compose.yaml
│   └── .env
├── projects/               # Your development projects
│   ├── my-laravel-app/
│   ├── client-website/
│   └── api-backend/
├── scripts/                # Core Podium scripts
│   ├── install.sh         # Environment installer
│   ├── new_project.sh     # Project creator
│   ├── setup_project.sh   # Project configurator
│   └── functions.sh       # Internal functions
└── extras/
    └── .podium_aliases    # Optional development aliases
```

## 🎯 Perfect For

### Laravel Developers
- **Multiple Laravel versions** (12.x, 11.x LTS, 10.x)
- **Instant setup** with database, Redis, email
- **Proper containerized tools** (Composer, Artisan)
- **Multi-project workflows**

### WordPress Developers  
- **Latest WordPress** or specific versions
- **Automatic database setup**
- **WP-CLI ready** in containers
- **Development-optimized** configuration

### PHP Teams
- **Consistent environments** across team members
- **Easy project sharing** and onboarding
- **Professional development workflow**
- **Docker-based isolation**

### Agencies and Freelancers
- **Quick client demos** via LAN access
- **Multiple client projects** running simultaneously  
- **Professional presentation** capabilities
- **Easy stakeholder access** from any device

## 🚀 Advanced Features

### Automatic Project Setup
- **Smart PHP version detection** from composer.json
- **Database creation** and configuration
- **Environment file generation** (.env for Laravel, wp-config.php for WordPress)
- **Hosts file management** for local domains
- **Port assignment** and networking

### Development Optimization
- **Redis caching** configured automatically
- **Email testing** with Exim4
- **File permissions** handled correctly
- **Cross-platform compatibility** built-in

### Safety Features
- **Trash integration** (projects moved to trash, not deleted)
- **Confirmation prompts** for destructive operations
- **Non-invasive installation** (minimal system changes)
- **Isolated environments** (no conflicts between projects)

## 💡 Why Use Podium?

### The Problem with Traditional PHP Development
- **Environment inconsistencies** between developers
- **Complex multi-container Docker setups** that are slow and resource-heavy
- **Manual configuration** for each new project
- **Host system pollution** with multiple PHP versions and tools
- **Difficult project sharing** and team onboarding

### The Podium Solution
- **Single command installation** sets up everything
- **Optimized single-container architecture** that's fast and efficient
- **Automatic project configuration** with zero manual setup
- **Clean containerized tools** that don't affect your host system
- **Instant project access** for demos and collaboration

---

*Podium: Professional PHP development made simple.* 🎭