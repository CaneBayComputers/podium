# Podium - PHP Development Environment

Podium is a comprehensive Docker-based development environment for PHP projects, featuring both a powerful Command Line Interface (CLI) and an intuitive Graphical User Interface (GUI). It provides seamless support for Laravel, WordPress, and custom PHP applications with integrated database services, caching, and development tools.

## 🚀 Quick Start

```bash
# Install and configure Podium
podium config

# Create a new Laravel project
podium new my-laravel-app --framework laravel --version 11.x --database mysql --no-github

# Start services and check status
podium start-services
podium status

# Launch the GUI
podium gui
```

## 📋 Commands Overview

### 🛠️ Development Tools
*Run from project directory*

| Command | Description |
|---------|-------------|
| `podium composer <args>` | Run Composer commands inside container |
| `podium art <args>` | Run Laravel Artisan commands |
| `podium wp <args>` | Run WordPress CLI commands |
| `podium php <args>` | Run PHP inside container |

### 📦 Container Execution
*Run from project directory*

| Command | Description |
|---------|-------------|
| `podium exec <cmd>` | Execute command as developer user |
| `podium exec-root <cmd>` | Execute command as root user |

### ⚡ Enhanced Laravel Commands
*Run from project directory*

| Command | Description |
|---------|-------------|
| `podium db-refresh` | Fresh migration + seed |
| `podium cache-refresh` | Clear all Laravel caches |

### 🔧 Service Management
*Run from project directory*

| Command | Description |
|---------|-------------|
| `podium redis <cmd>` | Run Redis CLI commands |
| `podium redis-flush` | Flush all Redis data |
| `podium memcache <cmd>` | Run Memcached commands via telnet |
| `podium memcache-flush` | Flush all Memcached data |
| `podium memcache-stats` | Show Memcached statistics |
| `podium supervisor <cmd>` | Run supervisorctl commands |
| `podium supervisor-status` | Show all supervised processes |

### 📁 Project Management

| Command | Description |
|---------|-------------|
| `podium up [project]` | Start project containers |
| `podium down [project]` | Stop project containers |
| `podium status [project]` | Show project status |
| `podium new [options]` | Create new project |
| `podium clone <repo>` | Clone existing project |
| `podium remove <project> [options]` | Remove project |

### ⚙️ System Management

| Command | Description |
|---------|-------------|
| `podium config` | Configure Podium environment |
| `podium start-services` | Start shared services |
| `podium stop-services` | Stop shared services |
| `podium config projects <path>` | Set custom projects directory |
| `podium gui` | Launch desktop GUI interface |

## 🎯 Command Options

### Global Options

| Option | Description |
|--------|-------------|
| `--json-output` | Clean JSON output (suppresses all text/colors) |

### New Project Options

| Option | Description | Values |
|--------|-------------|---------|
| `--framework <name>` | Framework type | `laravel`, `wordpress`, `php` |
| `--version <ver>` | Framework version | `11.x`, `10.x` (Laravel) \| `latest` (WP/PHP) |
| `--database <type>` | Database type | `mysql`, `postgres`, `mongodb` |
| `--github` | Create GitHub repository | - |
| `--no-github` | Skip GitHub repository creation | - |
| `--non-interactive` | Skip all prompts (use defaults) | - |

### Remove Project Options

| Option | Description |
|--------|-------------|
| `--force` | Skip confirmation prompts |
| `--force-db-delete` | Force database deletion without prompt |
| `--preserve-database` | Keep database (skip deletion) |

## 💡 Usage Examples

### Basic Development Workflow

```bash
# Create a new Laravel 11.x project with MySQL
podium new blog-app --framework laravel --version 11.x --database mysql --no-github

# Navigate to project and install dependencies
cd ~/podium-projects/blog-app
podium composer install

# Run migrations and seeders
podium art migrate --seed

# Start the project
podium up blog-app

# Check project status
podium status blog-app
```

### WordPress Development

```bash
# Create a WordPress project with PostgreSQL
podium new wp-site --framework wordpress --version latest --database postgres --no-github

# Install and activate plugins
podium wp plugin install woocommerce --activate
podium wp plugin list --status=active
```

### JSON Output for Automation

```bash
# Get project status as JSON for scripts/GUI
podium status --json-output

# Create project with JSON response
podium new api-service --framework laravel --version 11.x --database mysql --no-github --json-output

# Start services with JSON confirmation
podium start-services --json-output
```

### Service Management

```bash
# Start all shared services
podium start-services

# Check Redis status and flush cache
podium redis ping
podium redis-flush

# Monitor supervised processes
podium supervisor-status
podium supervisor restart all
```

### Advanced Usage

```bash
# Create Laravel project with GitHub integration
podium new enterprise-app --framework laravel --version 11.x --database postgres --github --non-interactive

# Execute custom commands in container
podium exec "php -v"
podium exec-root "apt update && apt install -y vim"

# Remove project but preserve database
podium remove old-project --force --preserve-database
```

## 🔌 JSON API Integration

Podium provides clean JSON output for programmatic integration, perfect for GUI applications and automation scripts:

```javascript
// Example: Create project via JSON API
const result = await exec('podium new myapp --framework laravel --version 11.x --database mysql --no-github --json-output');
const data = JSON.parse(result.stdout);

// Result:
{
  "action": "new_project",
  "project_name": "myapp",
  "framework": "laravel", 
  "database": "mysql",
  "status": "success"
}
```

### Available JSON Commands

- `podium status --json-output` - Project and service status
- `podium new --json-output` - Project creation confirmation
- `podium remove --json-output` - Project removal confirmation
- `podium start-services --json-output` - Service start confirmation
- `podium stop-services --json-output` - Service stop confirmation
- `podium up --json-output` - Project startup confirmation
- `podium down --json-output` - Project shutdown confirmation

## 🏗️ Architecture

### Services Included

- **MariaDB** - Primary database service
- **PostgreSQL** - Alternative database option
- **MongoDB** - NoSQL database option
- **Redis** - Caching and session storage
- **Memcached** - Additional caching layer
- **phpMyAdmin** - Database management interface

### Project Structure

```
~/podium-projects/
├── project1/
│   ├── docker-compose.yaml
│   ├── .env
│   └── [project files]
├── project2/
└── ...
```

### Network Configuration

Each project gets:
- Unique Docker IP address (10.236.58.x)
- Automatic `/etc/hosts` entry
- Mapped external port for LAN access
- Local URL: `http://project-name`
- LAN URL: `http://your-ip:port`

## 📱 GUI Interface

Launch the desktop GUI with:

```bash
podium gui
```

The GUI provides:
- Visual project management
- One-click project creation
- Service status monitoring
- Real-time logs and output
- Dark theme with modern UI

## 🔧 Configuration

### Initial Setup

```bash
# Run the configuration wizard
podium config

# Set custom projects directory
podium config projects /path/to/projects
```

### Environment Variables

- `PROJECTS_DIR` - Custom projects directory
- `JSON_OUTPUT` - Enable JSON output mode
- `NO_COLOR` - Disable colored output (deprecated - use `--json-output`)

## 📝 Important Notes

- **Directory Requirements**: Development tools (`composer`, `art`, `wp`, `php`, `exec`, `supervisor`) must be run from within a project directory
- **JSON Output**: Use `--json-output` for programmatic integration (GUI, scripts, automation)
- **Non-Interactive Mode**: Use `--non-interactive` with sensible defaults for automated deployment
- **Database Creation**: Databases are automatically created and configured for each project
- **Host Entries**: Local DNS entries are automatically managed in `/etc/hosts`

## 🚦 Getting Help

```bash
# Show comprehensive help
podium help

# Show command-specific help
podium new --help
podium remove --help
```

## 🔍 Troubleshooting

### Common Issues

1. **Services not starting**: Check Docker is running and ports are available
2. **Permission errors**: Ensure user is in `docker` group
3. **Database connection**: Verify database service is running with `podium status`
4. **Port conflicts**: Each project gets a unique port automatically assigned

### Debug Commands

```bash
# Check service status
podium status

# View container logs
docker logs [container-name]

# Check network connectivity
podium exec "ping mariadb"
```

---

**Podium** - Streamlined PHP development with Docker 🐳