# 🚀 Laravel Dev Environment Installer: Your One-Stop Solution for Seamless Setup on Ubuntu!

This installation script is designed to set up a complete development environment for Laravel projects on Ubuntu-based distributions. It automates the installation and configuration of essential tools such as Git, Docker, PHP, NPM, Composer, and AWS CLI. Additionally, the script configures user-specific settings and manages AWS credentials. By ensuring all dependencies and configurations are correctly set up, this script streamlines the initial setup process, allowing developers to quickly get started with their Laravel projects.

If you just want to get to coding, using, practicing or checking out Laravel right away then my friend you are at the right place. If you want things to go smoothly please carefully read and **follow the instructions**. This project was designed for the absolute beginner in mind but advanced users can find this useful. This project tries to take all of the time consuming and difficult development environment setup down to a few simple steps.

## TLDR

Git clone this repo on an Ubuntu based Linux distribution then run the `./install.sh` script.

## Linux (Ubuntu) Development

You can install this Laravel development environment directly on to Linux natively or in an existing Linux virtual machine.

**It must be installed on Ubuntu or an Ubuntu variant such as but not limited to: Mint, Xubuntu, ZorinOS or PopOS.**

Run the following commands in a terminal to install git version control if not installed already:

Install git:
```bash
sudo apt-get update

sudo apt-get install git
```

Clone this repo:
```bash
git clone https://github.com/CaneBayComputers/cbc-development.git
```

Run installer:
```bash
cd cbc-development/scripts

./install.sh
```

### Viewing and Accessing the MySQL Database

This project uses [phpMyAdmin](https://www.phpmyadmin.net/) to manage the database server however feel free to install a different client of choice.

If you are running a virtual machine you will have to install a different client within the virtual machine and not on the host machine.

To access phpMyAdmin simply open the browser and go to `http://cbc-phpmyadmin`.

If you are running a virtual machine there is a bookmark already saved in the pre-installed browser.