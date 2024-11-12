# 🚀 CBC Development Environment: Automated Project Setup

Welcome to the CBC Development Environment repository! This collection of scripts provides an automated way to set up and manage projects—whether Laravel, WordPress, or other PHP-based projects—on Ubuntu-based systems. The scripts handle everything from installation to project initialization and service management, ensuring a smooth development experience for users with basic Linux terminal knowledge.

## Quick Start Guide

### 1. Install Git
Ensure Git is installed before cloning the repository:
```bash
sudo apt-get update
sudo apt-get install git
```

### 2. Clone This Repository
Clone this repository to your local development environment:
```bash
git clone https://github.com/CaneBayComputers/cbc-development.git
cd cbc-development
```

### 3. Run the Installer
Navigate to the `scripts` directory:
```bash
cd scripts
```

Run the `install.sh` script to install essential development tools and set up your environment:
```bash
./install.sh
```

This script handles the installation of Docker and other necessary dependencies.

## Script Overview and Usage

**Note**: Always navigate to the `scripts` directory before running any of the scripts.

### Creating a New Project
Use the `new_project.sh` script to create a new project:
```bash
./new_project.sh <project_name> [organization]
```
- **`<project_name>`**: The name of your new project (required).
- **`[organization]`**: (Optional) Specifies a GitHub organization.

### Cloning an Existing Project
Clone and set up an existing project:
```bash
./clone_project.sh <repository> [project_name]
```
- **`<repository>`**: The URL of the repository to clone (required).
- **`[project_name]`**: (Optional) Specifies a custom name for the cloned project.

### Setting Up a Project
Set up an already downloaded project:
```bash
./setup_project.sh <project_name>
```
- **`<project_name>`**: The name of the project (required). This script configures the environment files, Docker services, and runs migrations if applicable.

### Removing a Project
Delete a project and associated entries:
```bash
./remove_project.sh <project_name>
```
- **`<project_name>`**: The name of the project (required). This script removes the project directory, any related `iptables` rules, the Docker container, and the `/etc/hosts` entry associated with the project. Optionally, it can also delete the project’s database if confirmed by the user.

## Managing Services

### Starting Projects with `startup.sh`
The `startup.sh` script starts projects that have been stopped or after a system reboot, ensuring the necessary Docker containers are running and accessible.

#### How to Use `startup.sh`
- **Start All Projects**:
  ```bash
  ./startup.sh
  ```
  This will start all projects in the `projects` folder and make them accessible in the browser.

- **Start a Specific Project**:
  ```bash
  ./startup.sh <project_name>
  ```

#### Automation on System Startup
To automatically start all projects when your system is powered on, add the `startup.sh` script to your startup applications:
```bash
gnome-terminal -- bash -c "<path to cbc-development>/startup.sh; exec bash"
```

### Stopping Projects with `shutdown.sh`
The `shutdown.sh` script stops running Docker containers and removes custom `iptables` rules for your projects.

#### How to Use `shutdown.sh`
- **Shut Down All Projects**:
  ```bash
  ./shutdown.sh
  ```
  Stops all Docker containers associated with projects in the `projects` folder and removes custom `iptables` rules.

- **Shut Down a Specific Project**:
  ```bash
  ./shutdown.sh <project_name>
  ```

## Accessing and Checking Project Status

To view project access information, use the `status.sh` script. This script checks if your projects are running and provides URLs for browser access.

### How to Use `status.sh`
- **Run Without Parameters**:
  ```bash
  ./status.sh
  ```
  Displays the status of all projects in the `projects` folder.

  **Example Output**:
  ```text
  PROJECT: ticket-tracker-pro
  PROJECT FOLDER: FOUND
  HOST ENTRY: FOUND
  DOCKER STATUS: RUNNING
  IPTABLES RULES: ESTABLISHED

  LOCAL ACCESS: http://ticket-tracker-pro
  LAN ACCESS: http://192.168.1.5:135
  WAN ACCESS: http://<hidden>:135
  ```

- **Run with a Project Name**:
  ```bash
  ./status.sh <project_name>
  ```
  Displays the status for the specified project. If issues are detected, the script provides suggestions for resolving them.

### Access Details Explained:
- **Local Access**: URL for accessing the project from the same computer or within the virtual machine (e.g., `http://<project_name>`).
- **LAN Access**: URL for accessing the project from other computers on the same network (e.g., `http://<LAN_IP>:<port>`).
- **WAN Access**: URL for accessing the project from outside the local network (e.g., `http://<WAN_IP>:<port>`), provided the specified port is forwarded to the LAN IP of the machine.

Use `status.sh` to ensure your projects are accessible and running as expected.

## Accessing phpMyAdmin
To manage your database, navigate to:
```
http://cbc-phpmyadmin
```
This interface helps you manage your databases easily.

## Important Notes on Project Management

### Setup Considerations

- **Project Directory Location**: All projects are saved to the `projects` folder within the `cbc-development` directory. Projects **cannot be renamed or moved** after installation, as this will break configurations and services.
- **Automated Configuration**: The `new_project.sh` script is currently designed only for Laravel projects, while `clone_project.sh` supports any PHP project. Both scripts automatically set up the database name, derived from the project name, and add an entry to the `/etc/hosts` file. These configurations are managed by the setup process and should **not be changed manually** to avoid breaking dependencies and expected configurations.

### Using Existing Docker-Compose Files
- **For Projects with Existing `docker-compose.yml`**: If a Laravel or PHP project already includes its own `docker-compose.yml` file, it’s recommended to follow that project’s original setup and installation instructions rather than using these scripts. Existing Docker configurations may have custom settings, dependencies, or services that differ from the setup provided by `cbc-development`. Using the project’s own setup will help ensure it functions as expected.

### Multiple Installations and VPC Configuration
- **Unique Networks**: Multiple `cbc-development` setups can run on the same machine, each using a unique `/24` VPC subnet.
- **Custom VPC Subnet**: To set a unique `10.x.x.x` network:
  1. Copy `.env.example` to `.env` in the `docker-stack` folder.
  2. Set the `VPC_SUBNET` (e.g., `10.217.153`) without the D class.

**Example of `.env` Configuration**:
```bash
VPC_SUBNET=10.217.153
STACK_ID=EjpyugOY
```

## Sending Emails
Configure Exim for sending emails using Amazon SES or Gmail as an SMTP relay. The configuration should be done in the `.env` file.

### Amazon SES Configuration
1. **Set Up Amazon SES**: [Guide](https://aws.amazon.com/ses/getting-started/)
2. **Generate SMTP Credentials**: [Instructions](https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html)
3. **Add to `.env`**:
   ```bash
   # Amazon SES Configuration
   EXIM_SMARTHOST="email-smtp.<region>.amazonaws.com:587"
   EXIM_PASSWORD="*.amazonaws.com:<SMTP_USERNAME>:<SMTP_PASSWORD>"
   ```

### Gmail Configuration
1. **App Passwords Required**: Enable 2-Step Verification and create an [App Password](https://support.google.com/accounts/answer/185833?hl=en).
2. **Add to `.env`**:
   ```bash
   # Gmail Configuration
   EXIM_SMARTHOST="smtp.gmail.com:587"
   EXIM_PASSWORD="*.google.com:yourAccount@gmail.com:<APP_PASSWORD>"
   ```

**Note**: Using Gmail for SMTP relay now requires OAuth 2.0 for third-party applications.

## Helper Commands

During the installation process, the `install.sh` script adds a set of helper commands to your `.bash_aliases` file in your home directory. These commands are known as **aliases**, which are shortcuts to longer commands that simplify everyday tasks. Below are some of the most useful aliases included and how they can be used:

### Key Aliases and Their Uses

1. **Project-Specific Commands**:
   - **`art-docker`**: Runs Laravel Artisan commands inside the Docker container. Before using this command, navigate to the project directory you want to work on.
     ```bash
     cd ~/projects/my-laravel-project
     art-docker migrate
     ```
   - **`composer-docker`**: Runs Composer commands inside the Docker container, allowing you to manage PHP dependencies for your project.
     ```bash
     cd ~/projects/my-laravel-project
     composer-docker install
     ```

2. **Git Workflow Shortcuts**:
   - **`gquick`**: Stages all new and modified files, commits them with a user-provided message, and pushes to the current branch. This is perfect for quick fixes and updates.
     ```bash
     cd ~/projects/my-project
     gquick
     # Follow the prompt to input your commit message
     ```

3. **System and Command Enhancements**:
   - **`sudo` Aliases**: Many commands like `apt-get`, `ifconfig`, `iptables`, and `mount` are aliased to automatically include `sudo`, saving you from manually typing it each time.
     ```bash
     apt-get update    # Runs as `sudo apt-get update`
     iptables -L       # Runs as `sudo iptables -L`
     ```

4. **Terminal Customization**:
   - Change the color of your terminal text for better readability or emphasis using these aliases:
     ```bash
     echo-red "This is a warning message"
     echo-green "Operation successful"
     echo-blue "Informational message"
     ```

5. **Mounting S3 Buckets**:
   - **`mount-bucket`**: Quickly mounts an Amazon S3 bucket to your local filesystem. It prompts for the bucket name and creates a directory under `~/s3/` to mount it.
     ```bash
     mount-bucket
     # Enter the bucket name when prompted
     ```

6. **WAN IP Display**:
   - **`whatismyip`**: Displays your current WAN (external) IP address. This is useful for verifying external access and is also used in the `status.sh` script for WAN access checks.
     ```bash
     whatismyip
     ```

7. **Viewing or Modifying Aliases**:
   - **`bash_aliases`**: Will open your `~/.bash_aliases` file in an editor and reload any chages upon exiting.
     ```bash
     bash_aliases
     ```

These aliases are designed to make your workflow smoother and faster, allowing you to focus more on your projects and less on repetitive terminal commands.