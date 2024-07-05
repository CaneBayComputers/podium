# 🚀 CBC Laravel Dev Environment Installer: Your One-Stop Solution for Seamless Setup on Ubuntu!

This installation script is designed to set up a complete development environment for CBC Laravel projects on Ubuntu-based distributions. It automates the installation and configuration of essential tools such as Git, Docker, PHP, NPM, Composer, and AWS CLI. Additionally, the script configures user-specific settings, manages AWS credentials, and clones necessary Git repositories. By ensuring all dependencies and configurations are correctly set up, this script streamlines the initial setup process, allowing developers to quickly get started with their projects.

If you just want to get to coding, using, practicing or checking out Laravel right away then my friend you are at the right place. If you want things to go smoothly please carefully read and **follow the instructions**. This project was designed for the absolute beginner in mind but advanced users can find this useful. This bootstrapped Laravel project tries to take all of the time consuming and difficult development environment setup down to a few simple steps.

## TLDR

Git clone this repo on an Ubuntu based Linux distribution then run the `./install.sh` script.

See more [Linux installation instructions below](#linux-development-option).

## Development Environment Options

Choose an installation option:  

- [Install on Windows](#windows-development-option)
- [Install on Linux](#linux-development-option)
- [Install on Mac](#mac-development-option)

To get to using this bootstrap environment after installing visit the [How To and Features](#how-to-and-features) section below.


### Windows Development Option

You will be installing VirtualBox which is software that enables you to run other operating systems on your current Windows system.

There are some requirements your system must meet for the virtual machine to run well.

> Minimum Requirements:
>
> 1. 8GB RAM memory
> 2. 40GB of available storage space
> 3. Quad-core CPU with virtualization (VT-x / AMD-V enabled)

DOWNLOAD ALL FILES IN THE SAME DIRECTORY!!!

Do NOT manually run any of the .exe files after downloading!

All files are safe and come from original source website.

##### Download each required file:

- [Click to download Microsoft C++ Redistributable 2019](https://aka.ms/vs/17/release/vc_redist.x64.exe)

- [Click to download VirtualBox](https://download.virtualbox.org/virtualbox/7.0.14/VirtualBox-7.0.14-161095-Win.exe)

- [Click to download VirtualBox extensions](https://download.virtualbox.org/virtualbox/7.0.14/Oracle_VM_VirtualBox_Extension_Pack-7.0.14.vbox-extpack)

- Right click [INSTALL.BAT](https://raw.githubusercontent.com/CaneBayComputers/cbc-windows-setup/main/INSTALL.BAT) and select *Save link as ...*

- [Click to download Linux Ubuntu 24](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-ubuntu-24.ova)

Open your Downloads folder and just double-click the INSTALL.BAT file.

__BEFORE YOU RUN THE INSTALLER KEEP READING...__

A blue warning box will pop up. Just select *More Info* and select *Run anyway*.

If the Microsoft Redistributable gives you a choice to *Repair*, *Uninstall* or *Close* just select *Close*.

Do NOT run VirtualBox after installation. Uncheck box to run after install.

Just answer `y` when it asks you.

You will have to enter the default password to get into the VM:

Pass: `1234`

After the installer is finished open the pre-installed web browser, look at the bookmarks bar and select the cbc-laravel-php7 or 8 bookmark.

You can also view the database with the cbc-phpmyadmin bookmark.

The two Laravel installations can be edited in Sublime Text which is pre-installed as well.

In Sublime Text you should see the two Laravel PHP folders talked about at the [top of this readme file](#).


### Linux Development Option

You can install this Laravel PHP bootstrap development environment directly on to Linux natively or in an existing Linux virtual machine.

> It must be installed on Ubuntu or an Ubuntu variant such as but not limited to: Mint, Xubuntu, ZorinOS or PopOS.

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

### Mac Development Option

Well, to be honest there isn't exactly one however you should be able to cobble it together by installing VirtualBox on Mac and importing one of the [Linux Ubuntu 24 OVA file](https://s3.amazonaws.com/canebaycomputers.cdn/virtual-machines/cbc-linux-ubuntu-24.ova) which will have Laravel PHP on it ready to go.



### Viewing and Accessing the MySQL Database

This project uses [phpMyAdmin](https://www.phpmyadmin.net/) to manage the database server however feel free to install a different client of choice.

If you are running a virtual machine you will have to install a different client within the virtual machine and not on the host machine.

To access phpMyAdmin simply open the browser and go to `http://cbc-phpmyadmin`.

If you are running a virtual machine there is a bookmark already saved in the pre-installed browser.


### Accessing Other Pre-Installed Services

There are other services running in the background due thanks to Docker.

To access these services you can refer to them by their Docker internal IP addresses:

>10.2.0.2 - [MariaDB (MySQL)](https://mariadb.org/)  
>10.2.0.4 - [MongoDB](https://www.mongodb.com/)  
>10.2.0.5 - [Redis](https://redis.io/)  
>10.2.0.6 - [Exim4 (Email server)](https://www.exim.org/)  
>10.2.0.7 - [Memcached](https://memcached.org/)