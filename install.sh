#!/bin/bash

set -e

shopt -s expand_aliases

alias echo-red='tput setaf 1 ; echo'
alias echo-green='tput setaf 2 ; echo'
alias echo-yellow='tput setaf 3 ; echo'
alias echo-blue='tput setaf 4 ; echo'
alias echo-magenta='tput setaf 5 ; echo'
alias echo-cyan='tput setaf 6 ; echo'
alias echo-white='tput setaf 7; echo'

if ! sudo -v; then echo "No sudo privileges. Root access required!"; exit 1; fi

if ! uname -a | grep Ubuntu > /dev/null; then

	echo "This script is for an Ubuntu/Mint/PopOS install!"

	exit 1

fi



###############################
# Set up git committer info
###############################

echo-cyan 'Git config settings ...'

echo-white

git config --global diff.tool meld

git config --global mergetool.keepBackup false

if ! git config user.name; then

	echo-yellow -ne 'Enter your full name for Git commits: '

	read GIT_NAME

	echo

	git config --global user.name "$GIT_NAME"

	sudo git config --global user.name "$GIT_NAME"

fi

if ! git config user.email; then

	echo-yellow -ne 'Enter your email address for Git commits: '

	read GIT_EMAIL

	echo

	git config --global user.email $GIT_EMAIL

	sudo git config --global user.email $GIT_EMAIL

fi

echo-green "Git configured!"

echo-white

echo



###############################
# AWS
###############################

echo-cyan 'Installing AWS ...'

echo-white

sudo apt-get -y -q install python3-pip python3-venv > /dev/null 2>&1

if ! aws --version > /dev/null 2>&1; then

	curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" > awscli-bundle.zip

	unzip -o awscli-bundle.zip

	rm -f awscli-bundle.zip

	sudo python3 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

	rm -fR awscli-bundle

fi

echo

echo-cyan 'Configuring AWS ...'

echo-white

if [ ! -d ~/.aws ]; then

	aws configure set default.region us-east-1

	aws configure set default.output json

	aws configure

fi

echo-green "AWS configured!"

echo-white

echo



###############################
# Remove crappy software
###############################

echo

echo-cyan 'Uninstalling some software ...'

echo-white

PKGS=( firefox firefox-locale-en gufw celluloid hexchat hypnotix redshift-gtk rhythmbox timeshift thunderbird warpinator webapp-manager mintbackup bulky mintwelcome onboard )

for PKG in "${PKGS[@]}"
do
	if sudo apt-get -y -q purge "$PKG"; then true; fi
done



###############################
# Init apt update
###############################

echo

echo-cyan 'Updating and upgrading package repos ...'

echo-white

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	
	echo \
	  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
	  https://download.docker.com/linux/ubuntu \
	  $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo apt-get update -y -q



###############################
# Init apt package installs
###############################

echo

echo-cyan 'Installing packages ...'

echo-white

sudo apt-get -y -q install \
	figlet \
	lolcat \
	bash-completion \
	openssh-server \
	nodejs \
	npm \
	default-mysql-client \
	apt-transport-https \
	dnsutils \
	ca-certificates \
	gnupg \
	lsb-release \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	xclip \
	pv \
	meld \
	imagemagick \
  inkscape

sudo apt-get -y -q install \
  php \
  php-bcmath \
  php-cli \
  php-common \
  php-fpm \
  php-gd \
  php-mongodb \
  php-opcache \
  php-curl \
  php-mbstring \
  php-mysql \
  php-redis \
  php-soap \
  php-zip \
  php-xml


if ! sudo docker-compose --version > /dev/null 2>&1; then

	sudo pip install docker-compose

fi

echo

echo-cyan 'Cleaning up ...'

echo-white

sudo apt-get -y -q autoremove

echo



###############################
# Composer
###############################

if ! composer --version > /dev/null 2>&1; then

	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

	sudo php composer-setup.php --install-dir=/usr/bin --filename=composer

	rm -f composer-setup.php

fi

echo



###############################
# Fonts
###############################

sudo cp -f ANSI\ Regular.flf /usr/share/figlet



###############################
# Repos
###############################

echo-cyan 'Installing repos ...'

cd ~

mkdir -p repos

cd repos

REPOS=( cbc-docker-stack cbc-docker-php7-nginx cbc-docker-php8-nginx cbc-laravel )

for REPO in "${REPOS[@]}"

do

	printf "\n\n------- $REPO\n"

	if [ ! -d $REPO ]; then

		git clone git@github.com:CaneBayComputers/$REPO.git

	fi

done



###############################
# Yay all done
###############################

echo

echo

echo "                                   .''.       
       .''.      .        *''*    :_\/_:     . 
      :_\/_:   _\(/_  .:.*_\/_*   : /\ :  .'.:.'.
  .''.: /\ :   ./)\   ':'* /\ * :  '..'.  -=:o:=-
 :_\/_:'.:::.    ' *''*    * '.\'/.' _\(/_'.':'.'
 : /\ : :::::     *_\/_*     -= o =-  /)\    '  *
  '..'  ':::'     * /\ *     .'/.\'.   '
      *            *..*         :
        *
        *" | lolcat -p 1 -F 0.2

echo

echo-green 'Yay! All done!!!'

echo-white