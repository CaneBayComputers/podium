# 🚀 CBC Development Environment: Automated Project Setup

Welcome to the CBC Development Environment repository! This collection of scripts provides an automated way to set up and manage projects—whether Laravel, WordPress, or other PHP-based projects—on Ubuntu-based systems. The scripts handle everything from installation to project initialization and service management, ensuring a smooth development experience.

## Prerequisites

Before starting, ensure your system is running an Ubuntu-based distribution and has internet access for downloading dependencies.

## Quick Start Guide

### 1. Clone This Repository

Clone this repository to your local development environment:

```bash
git clone https://github.com/CaneBayComputers/cbc-development.git
cd cbc-development
```

### 2. Run the Installer

Navigate to the `scripts` directory:

```bash
cd scripts
```

Run the `install.sh` script to install essential development tools and set up your environment:

```bash
./install.sh
```

This script installs tools such as Git, Docker, PHP, Composer, and other necessary dependencies.

---

## Script Overview and Usage

**Note**: Always navigate to the `scripts` directory before running any of the scripts.

### Creating a New Project

Use the `new_project.sh` script to create a new project. This script supports additional parameters for flexibility:

```bash
./new_project.sh <project_name> [organization]
```

- **`<project_name>`**: The name of your new project (required).
- **`[organization]`**: (Optional) Specifies a Github organization.

### Cloning an Existing Project

To clone and set up an existing project, use:

```bash
./clone_project.sh <repository> [project_name]
```

- **`<repository>`**: The URL of the repository to clone (required).
- **`[project_name]`**: (Optional) Specifies a custom name for the cloned project.

### Setting Up a Project

For setting up an already downloaded project, use:

```bash
./setup_project.sh <project_name>
```

- **`<project_name>`**: The name of the project (required). This script configures the environment files, Docker services, and runs migrations if applicable.

Here's the updated **Managing Services** section for your README, with a focus on the `startup.sh` script as a standalone item:

---

## Managing Services

### Starting Projects with `startup.sh`

The `startup.sh` script is essential for starting projects that have been stopped or after a system reboot. It ensures that the necessary Docker containers for your projects are running and accessible in your browser.

#### How to Use `startup.sh`

- **Start All Projects**:
  Running `startup.sh` without parameters will iterate through all projects in the `projects` folder and start their containers, making them accessible in the browser.

  ```bash
  ./startup.sh
  ```

- **Start a Specific Project**:
  You can specify a project name as a parameter to start only that project.

  ```bash
  ./startup.sh <project_name>
  ```

#### Automation on System Startup

To automatically start all projects when your computer or virtual machine is powered on, you can add the `startup.sh` script to your system's startup applications:

- **Add to Startup Applications**:
  In the Startup Applications manager, add the following command:

  ```bash
  gnome-terminal -- bash -c "<path to cbc-development>/startup.sh; exec bash"
  ```

This setup ensures that your projects start automatically without manual intervention after a reboot or power cycle.

### Stopping Projects with `shutdown.sh`

The `shutdown.sh` script is used to stop running Docker containers and remove custom `iptables` rules for your projects. It helps ensure that all project resources are properly shut down and network configurations are cleaned up.

#### How to Use `shutdown.sh`

- **Shut Down All Projects**:
  Running `shutdown.sh` without any arguments will stop all Docker containers associated with projects in the `projects` folder and remove any custom `iptables` rules.

  ```bash
  ./shutdown.sh
  ```

- **Shut Down a Specific Project**:
  Provide a project name as an argument to shut down only that specific project. This will stop the project's Docker container and remove any associated `iptables` rules.

  ```bash
  ./shutdown.sh <project_name>
  ```

#### What the Script Does:
- **Removes Custom `iptables` Rules**:
  The script identifies and removes `iptables` rules tagged with `cbc-rule` from the `filter`, `nat`, and `mangle` tables, ensuring network configurations related to the project are cleared.
- **Stops Docker Containers**:
  Iterates through the running containers in the `projects` folder and stops them. If a project name is provided, only that project's container is shut down.

After execution, `shutdown.sh` displays confirmation messages indicating that all specified containers have been stopped and network rules have been removed. This script is particularly useful for safely shutting down projects and cleaning up their network configurations.

---

## Viewing Project Access Information

To access and view the necessary information for opening your projects in a browser, use the `status.sh` script. This script provides a detailed status check of each project, ensuring you know how and where your projects can be accessed.

### How to Use `status.sh`

- **Run Without Parameters**:
  Running `status.sh` without any arguments will display the status of all projects in the `projects` folder.

  ```bash
  ./status.sh
  ```

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
  Specify a project name to check the status of just that project:

  ```bash
  ./status.sh <project_name>
  ```

  If there is an issue, such as a missing project folder or container not running, the script will provide suggestions to help resolve the issue.

### What the Script Checks:
1. **Project Folder**: Verifies that the project folder exists.
2. **Host Entry**: Confirms that there is an entry for the project in `/etc/hosts`.
3. **Docker Status**: Ensures that the Docker container for the project is running.
4. **`iptables` Rules**: Checks that network routing rules are set for proper access.

### Access Details Explained:
The `status.sh` script provides the following URLs for project access:

- **Local Access**:
  - The URL to access the project from the same computer or within the virtual machine running the project (e.g., `http://<project_name>`).

- **LAN Access**:
  - The URL that allows access from other computers on the same local network (e.g., `http://<LAN_IP>:<port>`).

- **WAN Access**:
  - The URL for accessing the project from outside the local network (e.g., `http://<WAN_IP>:<port>`). This requires that the specified port is forwarded to the LAN IP address of the running machine.

Use `status.sh` to ensure your projects are running as expected and to gather all the necessary information for browser access.

## Accessing phpMyAdmin

To manage your database, open a web browser and navigate to:

```
http://cbc-phpmyadmin
```

This allows you to handle your database in a user-friendly interface.

## Additional Information

- **Run from `scripts` Directory**: Always navigate to `cbc-development/scripts` before running any script to ensure paths and dependencies are correctly resolved.
- **Pre-check Environment**: Run `pre_check.sh` to ensure your environment is set up correctly before starting a project.
- **Environment Flexibility**: The scripts are designed to support various project types, making them ideal for mixed development environments.

Here's the final additional section for the README, including the hosts file example and a note on the `.env.example` configuration:

---

## Important Notes on Project Management

### Project Directory Limitations
- **Project Location**: All projects are saved to the `projects` folder within the `cbc-development` directory. Projects **cannot be renamed or moved** after installation; doing so will cause configurations and services to break.
- **Project Removal**: Currently, there is no automated way to remove a project. If you need to delete a project, you must manually:
  - Remove the project folder.
  - Delete the associated entry from the `/etc/hosts` file.
  - Stop and remove the Docker container related to the project.

### Example of Hosts File Entries
When a project is installed, the following type of entries are added to the `/etc/hosts` file:

```
10.217.153.2        mariadb
10.217.153.3        phpmyadmin
10.217.153.4        mongo
10.217.153.5        redis
10.217.153.6        exim4
10.217.153.7        memcached
10.217.153.135      ticket-tracker-pro
10.217.153.235      letter-link-api
```

- The IP addresses (e.g., `10.217.153.x`) are specific to the `cbc-development` setup and correspond to different services and projects. Each project and service gets a unique D class IP address within the VPC subnet.

### Multiple Installations and VPC Configuration
- **Unique Networks**: It is possible to run multiple `cbc-development` setups on the same machine, as each setup uses a unique `/24` VPC subnet.
- **VPC Details**: The generated network operates on a `10.x.x.x` subnet, such as `10.217.x.x`, to minimize conflicts with local networks.
- **Custom VPC Subnet**: If you need a unique `10.x.x.x` network for a specific `cbc-development` installation:
  1. Go to the `docker-stack` folder.
  2. Copy the `.env.example` file to `.env`.
  3. Manually set the `VPC_SUBNET`, leaving off the D class (e.g., `10.217.153`).

**Example of `.env.example` Configuration**:
```bash
# Cannot change once set and installed
VPC_SUBNET=10.217.153
STACK_ID=EjpyugOY

# Amazon SES
#EXIM_SMARTHOST="email-smtp.us-east-1.amazonaws.com:25"
#EXIM_PASSWORD="*.amazonaws.com:<ACCESS_KEY_ID>:<SECRET_ACCESS_KEY>"

# Gmail
#EXIM_SMARTHOST="smtp.gmail.com::587"
#EXIM_PASSWORD="*.google.com:yourAccount@gmail.com:yourPassword"
```

- **VPC_SUBNET**: Define a unique C class subnet without the D class.
- **STACK_ID**: Set to 8 random alphanumeric characters to ensure unique identification.

This setup ensures that multiple `cbc-development` environments can run independently without IP conflicts.

### Sending Emails

To configure Exim for sending emails, you can use either Amazon Simple Email Service (SES) or Gmail as your SMTP relay. Below are the steps and considerations for each:

#### Amazon SES Configuration

1. **Set Up Amazon SES**: Sign up for Amazon SES and verify your domain or email addresses. This process is detailed in the [Amazon SES Getting Started Guide](https://aws.amazon.com/ses/getting-started/).

2. **Generate SMTP Credentials**: Create SMTP credentials in the AWS Management Console. Instructions are available in the [Amazon SES SMTP Credentials Guide](https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html).

3. **Configure Exim**: In your `.env` file, set the following variables:

   ```bash
   EXIM_SMARTHOST="email-smtp.<region>.amazonaws.com:587"
   EXIM_PASSWORD="*.amazonaws.com:<SMTP_USERNAME>:<SMTP_PASSWORD>"
   ```

   Replace `<region>`, `<SMTP_USERNAME>`, and `<SMTP_PASSWORD>` with your specific details.

4. **Allow Specific Domains and Emails**: Ensure that the domains and email addresses you intend to send emails from are verified in your Amazon SES account. This is crucial for successful email delivery.

#### Gmail Configuration

1. **Enable Access for Less Secure Apps**: Gmail has deprecated the "Allow less secure apps" feature. As of September 30, 2024, third-party apps that use only a username and password to access Google Accounts are no longer supported. Instead, you must use OAuth 2.0 for authentication. More information is available in Google's [Transition from less secure apps to OAuth](https://support.google.com/a/answer/14114704?hl=en) guide.

2. **Generate an App Password**: If your account has 2-Step Verification enabled, you can create an app-specific password:
   - Go to your [Google Account Security Settings](https://myaccount.google.com/security).
   - Under "Signing in to Google," select "App passwords."
   - Follow the prompts to generate a new app password.

   Detailed instructions are provided in Google's [App Passwords Help Center](https://support.google.com/accounts/answer/185833?hl=en).

3. **Configure Exim**: In your `.env` file, set the following variables:

   ```bash
   EXIM_SMARTHOST="smtp.gmail.com:587"
   EXIM_PASSWORD="*.google.com:yourAccount@gmail.com:<APP_PASSWORD>"
   ```

   Replace `yourAccount@gmail.com` and `<APP_PASSWORD>` with your Gmail address and the app password you generated.

**Note**: Due to recent security updates, using Gmail for SMTP relay with just a username and password is no longer supported. Implementing OAuth 2.0 is now required for third-party applications.

For more detailed information, refer to the following resources:

- [Amazon SES Getting Started Guide](https://aws.amazon.com/ses/getting-started/)
- [Amazon SES SMTP Credentials Guide](https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html)
- [Google's Transition from less secure apps to OAuth](https://support.google.com/a/answer/14114704?hl=en)
- [Google's App Passwords Help Center](https://support.google.com/accounts/answer/185833?hl=en)

By following these guidelines, you can configure Exim to send emails using either Amazon SES or Gmail as your SMTP relay.