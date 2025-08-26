# 🎭 Podium: The Complete PHP Development Platform

**Professional PHP development environments in one command. Any framework. Any project. Anywhere.**

Podium is the most comprehensive Docker-based PHP development platform available, designed for modern developers, teams, and agencies who demand **professional workflows without complexity**. Create production-ready Laravel, WordPress, and PHP projects in seconds, complete with databases, caching, and professional tooling - all managed through an intuitive CLI and beautiful desktop GUI.

## ✨ What Makes Podium Revolutionary

### 🎯 **Zero-Configuration Philosophy**
- **One installer** configures your entire development stack
- **One command** creates production-ready projects with full database setup
- **Zero manual configuration** - everything works perfectly out of the box
- **Cross-platform excellence** - Linux, macOS, Windows (WSL2) with native performance

### 🏗️ **Multi-Project Architecture Excellence**
- **Run unlimited projects simultaneously** - Laravel, WordPress, PHP all at once
- **Framework agnostic** - Mix Laravel 11.x with WordPress 6.x and legacy PHP seamlessly
- **Shared services architecture** - One MySQL/Redis/phpMyAdmin stack serves all projects efficiently
- **Perfect isolation** - Projects never interfere with each other

### 🌐 **Professional Demo & Collaboration Features**
- **Local development**: `http://project-name` for focused coding
- **LAN access**: `http://your-ip:port` for instant team demos and client presentations
- **Mobile testing**: Access projects from phones, tablets, any device on your network
- **Stakeholder access**: Show progress to clients and managers from any device

### 🖥️ **Beautiful Desktop GUI Management**
- **Native desktop application** with modern, intuitive interface
- **Real-time monitoring** - Live status updates for all projects and services
- **One-click operations** - Start, stop, create, remove projects with visual controls
- **System health dashboard** - Monitor Docker, databases, and service health
- **Cross-platform native apps** - Linux, Windows, macOS with platform-specific optimizations

## 🚀 Installation & Quick Start

### Linux (Ubuntu/Debian) - Recommended
```bash
# Download and install .deb package (completely automated setup)
curl -L -o podium-cli_latest.deb https://github.com/CaneBayComputers/podium-cli/releases/latest/download/podium-cli_latest.deb
sudo dpkg -i podium-cli_latest.deb

# Configure your development environment
podium config

# Create your first project
podium new my-awesome-app --framework laravel --version 11.x --database mysql --github

# Start coding immediately at:
# http://my-awesome-app
```

### macOS
```bash
# Homebrew installation with automatic dependency management
curl -O https://raw.githubusercontent.com/CaneBayComputers/podium-cli/main/releases/homebrew/podium-cli.rb
brew install --formula ./podium-cli.rb

# Configure and create your first project
podium config
podium new my-awesome-app
```

### Windows (WSL2)
```bash
# Install Ubuntu WSL2 first, then:
curl -L -o podium-cli_latest.deb https://github.com/CaneBayComputers/podium-cli/releases/latest/download/podium-cli_latest.deb
sudo dpkg -i podium-cli_latest.deb

# Ensure Docker Desktop is running with WSL2 integration
podium config
podium new my-awesome-app
```

### Launch the GUI (Included in CLI)
```bash
# Launch the beautiful desktop GUI
podium gui
```

## 📋 Complete Command Reference

### 🏗️ Project Management Commands

#### `podium new` - Create New Projects
```bash
# Interactive mode (recommended for beginners)
podium new
podium new [project_name]
podium new [project_name] [organization]

# Non-interactive mode (perfect for automation and advanced users)
podium new <project_name> [organization] [version] [options]
```

**Arguments:**
- `project_name` - Name of the project to create
- `organization` - GitHub organization (optional)
- `version` - Framework version (optional)

**Options:**
- `--framework TYPE` - Framework type: `laravel`, `wordpress`
- `--version VERSION` - Specific version: `12.x`, `11.x`, `10.x`, `latest`, `6.x`
- `--database TYPE` - Database type: `mysql`, `postgres`, `mongo`
- `--github` - Create GitHub repository automatically
- `--no-github` - Skip GitHub repository creation
- `--help` - Show detailed usage information

**Examples:**
```bash
# Interactive project creation
podium new

# Laravel 11.x with PostgreSQL and GitHub repo
podium new my-api --framework laravel --version 11.x --database postgres --github

# WordPress with MySQL, no GitHub
podium new client-site --framework wordpress --database mysql --no-github

# Laravel for organization with specific version
podium new team-project my-org 11.x --database postgres
```

#### `podium clone` - Clone Existing Projects
```bash
podium clone <repository> [project_name]
```

**Arguments:**
- `repository` - Git repository URL (required)
- `project_name` - Custom project name (optional, uses repo name if not specified)

**Features:**
- Automatic framework detection (Laravel/WordPress/PHP)
- Environment file configuration
- Database setup and connection
- Dependency installation
- Container startup

**Examples:**
```bash
# Clone with original name
podium clone https://github.com/laravel/laravel

# Clone with custom name
podium clone https://github.com/user/project my-custom-name

# Clone from different Git providers
podium clone git@gitlab.com:user/project.git
```

#### `podium remove` - Safe Project Removal
```bash
podium remove <project_name> [options]
```

**Arguments:**
- `project_name` - Name of project to remove (required)

**Options:**
- `--force-trash-project` - Skip confirmation for project directory removal
- `--force-db-delete` - Skip confirmation for database deletion
- `--force` - Skip all confirmations (combines both flags above)
- `--help` - Show detailed usage information

**Safety Features:**
- Projects moved to system trash (recoverable)
- Database deletion requires confirmation (unless forced)
- Docker containers cleanly removed
- Hosts file entries cleaned up
- All project configurations removed

**Examples:**
```bash
# Safe removal with confirmations
podium remove old-project

# Force removal without prompts (perfect for automation)
podium remove test-project --force

# Remove project but confirm database deletion
podium remove my-project --force-trash-project
```

### 🔄 Service Management Commands

#### `podium up` - Start Projects
```bash
# Start all projects
podium up

# Start specific project
podium up <project_name>
```

**Features:**
- Starts Docker containers
- Configures networking and port mapping
- Updates hosts file entries
- Makes projects accessible via browser
- Starts shared services if needed

#### `podium down` - Stop Projects
```bash
# Stop all projects
podium down

# Stop specific project
podium down <project_name>
```

**Features:**
- Gracefully stops Docker containers
- Preserves all project data
- Cleans up networking configurations
- Maintains database data and configurations

#### `podium status` - Project Status & Health
```bash
# Check all projects and services
podium status

# Check specific project
podium status <project_name>

# JSON output for automation/GUI
podium status --json-output
```

**Options:**
- `--json-output` - Output status in JSON format for parsing
- `--no-coloring` - Disable ANSI color codes for clean parsing

**Status Information:**
- Project folder existence
- Host file entries
- Docker container status
- Port mappings and accessibility
- Local and LAN access URLs
- Troubleshooting suggestions
- Shared services health

### 🖥️ GUI Management

#### `podium gui` - Launch Desktop Interface
```bash
# Launch the desktop GUI application
podium gui
```

**GUI Features:**
- **Visual project dashboard** with real-time status
- **One-click project operations** (create, start, stop, remove)
- **Service health monitoring** with live updates
- **System resource monitoring** and alerts
- **Dark/light theme support** with colorful accents
- **Debug logging** available as runtime option
- **Cross-platform native experience**

### ⚙️ System Management Commands

#### `podium config` - Environment Configuration
```bash
# Configure Podium development environment
podium config

# Set custom projects directory
podium config projects <path>
```

**Configuration Process:**
- Git setup and authentication
- GitHub CLI authentication
- AWS CLI configuration (optional)
- Docker network setup
- Hosts file configuration
- Service startup and health verification

#### `podium start-services` - Start Shared Services
```bash
podium start-services
```

**Shared Services:**
- **MariaDB** - Database server for all projects
- **phpMyAdmin** - Web-based database management
- **Redis** - High-performance caching and sessions
- **Memcached** - Additional caching layer
- **PostgreSQL** - Alternative database option
- **MongoDB** - NoSQL database support

#### `podium stop-services` - Stop Shared Services
```bash
podium stop-services
```

**Features:**
- Graceful service shutdown
- Data preservation
- Network cleanup
- Resource deallocation

### 🛠️ Development Tools (Containerized)

#### Composer - PHP Dependency Management
```bash
# Run Composer inside project container
podium composer <args>

# Common Composer commands
podium composer install
podium composer require laravel/sanctum
podium composer update
podium composer dump-autoload
podium composer show
```

#### Laravel Artisan - Framework Commands
```bash
# Run Laravel Artisan inside container
podium art <args>

# Common Artisan commands
podium art migrate
podium art migrate:refresh --seed
podium art make:controller UserController
podium art make:model Post -m
podium art tinker
podium art queue:work
podium art serve
podium art route:list
podium art cache:clear
```

#### WordPress CLI - WordPress Management
```bash
# Run WP-CLI inside container
podium wp <args>

# Common WP-CLI commands
podium wp plugin list
podium wp plugin install akismet --activate
podium wp user create admin admin@example.com --role=administrator
podium wp db export backup.sql
podium wp core update
podium wp theme list
podium wp post list
```

#### PHP - Direct PHP Execution
```bash
# Run PHP inside container
podium php <args>

# Common PHP commands
podium php -v
podium php -m
podium php script.php
podium php -i | grep extension_dir
```

### 🚀 Enhanced Development Commands

#### Laravel-Specific Shortcuts
```bash
# Database refresh with seeding
podium db-refresh

# Clear all Laravel caches (config, route, view, etc.)
podium cache-refresh
```

#### Redis Management
```bash
# Redis CLI access
podium redis <cmd>

# Common Redis commands
podium redis KEYS "*"
podium redis GET key_name
podium redis SET key_name value

# Utility commands
podium redis-flush        # Flush all Redis data
```

#### Memcached Management
```bash
# Memcached commands via telnet interface
podium memcache <cmd>

# Utility commands
podium memcache-flush     # Flush all Memcached data
podium memcache-stats     # Show Memcached statistics
```

#### Process Management
```bash
# Supervisor process control
podium supervisor <cmd>
podium supervisor-status  # Show all supervised processes
```

### 🔧 Container Access Commands

#### Development Container Access
```bash
# Execute commands as developer user
podium exec <cmd>
podium exec bash          # Interactive bash shell
podium exec ls -la        # List files

# Execute commands as root user
podium exec-root <cmd>
podium exec-root bash     # Root bash shell
podium exec-root apt update  # System administration
```

### 📊 Global Options

#### Output Control
```bash
# Disable ANSI color codes (perfect for automation)
podium <command> --no-coloring

# JSON output for programmatic parsing
podium status --json-output
podium <command> --json-output
```

#### Help System
```bash
# Show general help
podium help

# Show command-specific help
podium new --help
podium remove --help
podium clone --help
```

## 🏗️ Architecture & Technical Excellence

### Shared Services Architecture
**One optimized stack serves all projects:**
- **MariaDB 11.8** - High-performance MySQL-compatible database
- **Redis 7.x** - Advanced caching and session storage
- **phpMyAdmin** - Professional web database interface
- **Memcached** - Additional high-speed caching layer
- **PostgreSQL 16** - Advanced relational database option
- **MongoDB 7** - Modern document database support

### Per-Project Container Optimization
**Each project gets its own optimized environment:**
- **Custom-built Docker images** with PHP 8.x, Nginx, and all tools
- **Automatic PHP version detection** from composer.json requirements
- **Framework-specific optimizations** for Laravel, WordPress, and PHP
- **Unique port mapping** for LAN access and team collaboration
- **Live code editing** with volume mounting for instant development

### Network Architecture
- **Custom Docker networks** with automatic IP assignment
- **Hosts file management** for clean local domain access
- **Port mapping system** for LAN accessibility
- **Network isolation** between projects for security

### Cross-Platform Excellence
- **Linux native performance** with .deb package distribution
- **macOS optimization** with Homebrew integration and Apple Silicon support
- **Windows WSL2 compatibility** with full Docker Desktop integration
- **Consistent experience** across all platforms

## 🎯 Perfect Use Cases

### Laravel Development Teams
- **Multiple Laravel versions** (12.x, 11.x LTS, 10.x) running simultaneously
- **Instant project setup** with database, Redis, and professional tooling
- **Team consistency** - everyone uses identical environments
- **Professional workflows** with containerized Composer and Artisan

### WordPress Agencies
- **Client project isolation** - multiple WordPress sites running concurrently
- **Version flexibility** - Latest WordPress or specific client requirements
- **WP-CLI integration** - Professional WordPress development tools
- **Easy client demos** via LAN access from any device

### Full-Stack Development Teams
- **Mixed technology stacks** - Laravel APIs with WordPress frontends
- **Microservices architecture** - Multiple projects serving different purposes
- **Database variety** - MySQL, PostgreSQL, MongoDB all available
- **Professional presentation** capabilities for stakeholder reviews

### Freelancers & Consultants
- **Quick client onboarding** - Show progress instantly via LAN access
- **Professional presentation** - Clients can access projects from their devices
- **Project isolation** - Keep client work completely separate
- **Rapid prototyping** - New projects ready in under 60 seconds

## 🖥️ Desktop GUI Features

### Visual Project Management
- **Project dashboard** with real-time status indicators
- **One-click operations** - Create, start, stop, remove projects visually
- **Service monitoring** - Live status of all shared services
- **Resource usage** - Monitor Docker, memory, and system health

### Modern Interface Design
- **Dark/grey theme** with colorful accents for professional appearance
- **Native platform integration** - Follows OS design guidelines
- **Responsive layout** - Adapts to different screen sizes
- **Intuitive controls** - Designed for both technical and non-technical users

### Advanced Features
- **Debug logging** - Runtime option for troubleshooting
- **System health monitoring** - Proactive issue detection
- **Automated installation** - GUI-driven setup process
- **Cross-platform consistency** - Same experience on Linux, Windows, macOS

### Integration with CLI
- **Seamless interoperability** - GUI and CLI work together perfectly
- **Real-time synchronization** - Changes in CLI immediately reflected in GUI
- **Command execution** - GUI can execute CLI commands with visual feedback
- **Status synchronization** - Live updates from CLI operations

## 🌟 Professional Benefits

### Development Efficiency
- **60-second project creation** - From command to coding in under a minute
- **Zero configuration overhead** - No time wasted on environment setup
- **Consistent tooling** - Same commands work across all projects
- **Professional workflows** - Industry-standard development practices built-in

### Team Collaboration
- **Environment consistency** - "Works on my machine" problems eliminated
- **Easy project sharing** - Clone and run any team member's project instantly
- **Professional demos** - Show work to anyone on your network
- **Onboarding acceleration** - New team members productive immediately

### Client & Stakeholder Management
- **Instant accessibility** - Projects available via any device on your network
- **Professional presentation** - Clean URLs and professional appearance
- **Progress demonstration** - Show development progress in real-time
- **Mobile compatibility** - Clients can review work on phones and tablets

### System Cleanliness
- **No host system pollution** - All tools run in containers
- **Version conflict elimination** - Multiple PHP versions without conflicts
- **Easy cleanup** - Complete project removal with one command
- **Professional separation** - Work projects don't affect personal system

## 📦 Distribution & Installation

### Linux (.deb Package) - Recommended
```bash
curl -L -o podium-cli_latest.deb https://github.com/CaneBayComputers/podium-cli/releases/latest/download/podium-cli_latest.deb
sudo dpkg -i podium-cli_latest.deb
```
- **Professional .deb package** with proper dependency management
- **Automatic Docker installation** and configuration
- **System integration** with correct permissions and paths
- **Desktop menu integration** for GUI application

### macOS (Homebrew Formula)
```bash
curl -O https://raw.githubusercontent.com/CaneBayComputers/podium-cli/main/releases/homebrew/podium-cli.rb
brew install --formula ./podium-cli.rb
```
- **Native Homebrew formula** with dependency resolution
- **Docker Desktop integration** with automatic configuration
- **Apple Silicon optimization** for M1/M2 Macs
- **macOS-specific optimizations** for native performance

### Windows (WSL2)
```bash
# Install via Ubuntu WSL2
sudo dpkg -i podium-cli_latest.deb
```
- **Full WSL2 compatibility** with Linux-level performance
- **Docker Desktop integration** with WSL2 backend
- **Windows filesystem access** for seamless development
- **Native Windows GUI** support through WSL2 integration

## 🔄 Upgrade & Maintenance

### CLI Updates
```bash
# Download and install latest .deb package
curl -L -o podium-cli_latest.deb https://github.com/CaneBayComputers/podium-cli/releases/latest/download/podium-cli_latest.deb
sudo dpkg -i podium-cli_latest.deb
```

### GUI Updates
- **Automatic update notifications** within the application
- **One-click updates** for seamless upgrade experience
- **Backward compatibility** with existing projects and configurations

## 🤝 Support & Community

### Documentation
- **Comprehensive README** with all commands and options
- **Video tutorials** for visual learners
- **Best practices guide** for team implementation
- **Troubleshooting guide** for common issues

### Community Support
- **GitHub Issues** for bug reports and feature requests
- **Discussion forum** for community support and tips
- **Professional support** available for enterprise users

---

**Podium: Where professional PHP development meets simplicity.** 🎭

*Transform your development workflow today - from complex Docker configurations to one-command project creation.*