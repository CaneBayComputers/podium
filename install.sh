#!/bin/bash

set -e

source .bash_aliases

shopt -s expand_aliases

if ! sudo -v; then echo "No sudo privileges. Root access required!"; exit 1; fi

if ! uname -a | grep Ubuntu > /dev/null; then

	echo "This script is for an Ubuntu/Mint/PopOS install!"

	exit 1

fi



###############################
# Set up git committer info
###############################

echo

echo-cyan 'Git config settings ...'

echo-white

git config --global diff.tool meld

git config --global mergetool.keepBackup false

if ! git config user.name; then

	echo-yellow -ne 'Enter your full name for Git commits. Leave blank if unknown. You can re-run installer after you have this info: '

	echo-white -ne

	read GIT_NAME

	if ! [ -z "${GIT_NAME}" ]; then

		git config --global user.name "$GIT_NAME"

		sudo git config --global user.name "$GIT_NAME"

	fi

	echo

fi

if ! git config user.email; then

	echo-yellow -ne 'Enter your email address for Git commits. Leave blank if unknown. You can re-run installer after you have this info: '

	echo-white -ne

	read GIT_EMAIL

	if ! [ -z "${GIT_EMAIL}" ]; then

		git config --global user.email $GIT_EMAIL

		sudo git config --global user.email $GIT_EMAIL

	fi

	echo

fi

if ! [ -f ~/.ssh/id_rsa ]; then

  if ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa; then true; fi

  echo

  echo-blue 'Copy and paste the following into your Github account under SSH Keys:'

  echo-white

  cat ~/.ssh/id_rsa.pub

  echo ; echo

  read -n 1 -r -s -p $'Press enter to continue...\n'

  echo ; echo

fi

echo-green "Git configured!"

echo-white

echo



###############################
# Set S3FS credentials
###############################

if ! [ -f ~/.passwd-s3fs ]; then

  echo-yellow -ne 'Enter your S3 credentials. If you do not have this info just leave blank. You can re-run the installer again later after you have this information. Example: ACCESS_ID:SECRET_KEY : '

  echo-white -ne

	read S3_CREDS

	if ! [ -z "${S3_CREDS}" ]; then

		echo $S3_CREDS > ~/.passwd-s3fs

		chmod 600 ~/.passwd-s3fs

	fi

fi

echo-white

echo



###############################
# Initial update and package installations
###############################

echo-cyan 'Updating and installing initial packages ...'

echo-white

sudo apt-get update -y

sudo apt-get -y install ca-certificates curl python3-pip python3-venv

echo

echo



###############################
# AWS
###############################

echo-cyan 'Installing AWS ...'

mkdir -p ~/s3

echo-white

if ! aws --version > /dev/null 2>&1; then

	curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" > awscli-bundle.zip

	unzip -o awscli-bundle.zip

	rm -f awscli-bundle.zip

	sudo python3 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

	rm -fR awscli-bundle

fi

echo

echo-green "AWS installed!"

echo-white

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
# Docker
###############################

echo

echo-cyan 'Installing Docker ...'

echo-white

if ! [ -f /etc/apt/sources.list.d/docker.list ]; then

  sudo install -m 0755 -d /etc/apt/keyrings

  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y -q

fi

echo

echo-green "Docker installed!"

echo-white



###############################
# Create Docker volume
###############################

echo

echo-cyan 'Creating Docker volume ...'

echo-white

if ! sudo docker volume ls | grep vol-cbc-docker-stack; then

  sudo docker volume create vol-cbc-docker-stack

fi

echo

echo-green "Docker volume created!"

echo-white



###############################
# Init apt package installs
###############################

echo

echo-cyan 'Installing packages ...'

echo-white

sudo apt-get -y install \
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
	docker-buildx-plugin \
	docker-compose-plugin \
	containerd.io \
	xclip \
	pv \
	meld \
	imagemagick \
	s3fs \
  php \
  php-bcmath \
  php-cli \
  php-common \
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

echo

echo-cyan 'Cleaning up ...'

echo-white

sudo apt-get -y -q autoremove

echo



###############################
# Composer
###############################

echo

echo-cyan 'Installing Composer ...'

echo-white

if ! composer --version > /dev/null 2>&1; then

	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

	sudo php composer-setup.php --install-dir=/usr/bin --filename=composer

	rm -f composer-setup.php

fi

echo

echo-green "Composer installed!"

echo-white

echo



###############################
# Hosts
###############################
echo-cyan 'Writing domain names to hosts file ...'

echo-white

while read HOST; do

	if ! cat /etc/hosts | grep "$HOST"; then

		echo "$HOST" | sudo tee -a /etc/hosts

	fi

done < hosts.txt

echo



###############################
# Fonts
###############################

sudo cp -f ANSI\ Regular.flf /usr/share/figlet



###############################
# Repos
###############################

echo-cyan 'Installing repos ...'

echo-white

cd ~

mkdir -p repos

cd repos

REPOS=( certbot-bash-wrapper cbc-docker-stack cbc-docker-php7-nginx cbc-docker-php8-nginx cbc-laravel-php7 cbc-laravel-php8 )

for REPO in "${REPOS[@]}"

do

	printf "\n------- $REPO\n"

	if [ ! -d $REPO ]; then

		git clone https://github.com/CaneBayComputers/$REPO.git

	fi

done

echo



###############################
# Create self signed keys
###############################

echo-cyan 'Setting up CBC Nginx SSL PHP7...'

echo-white

cd cbc-docker-php7-nginx/ssl

if ! [ -f openssl.cnf ]; then

  cp -f openssl.example.cnf openssl.cnf

  source create_self_signed.sh

fi

cd ../..

echo


echo-cyan 'Setting up CBC Nginx SSL PHP8...'

echo-white

cd cbc-docker-php8-nginx/ssl

if ! [ -f openssl.cnf ]; then

  cp -f openssl.example.cnf openssl.cnf

  source create_self_signed.sh

fi

cd ../..

echo



###############################
# Set up Laravel repos
###############################

echo-cyan 'Setting up CBC Laravel PHP7...'

echo-white

cd cbc-laravel-php7

source ./install.sh

if ! [ -f .env ]; then

  cp -f .env.example .env

  art-laravel-php7 key:generate

fi

if ! [ -f docker-compose.yaml ]; then

  cp -f docker-compose.example.yaml docker-compose.yaml

fi

cd ..

echo


echo-cyan 'Setting up CBC Laravel PHP8...'

echo-white

cd cbc-laravel-php8

source ./install.sh

if ! [ -f .env ]; then

  cp -f .env.example .env

  art-laravel-php8 key:generate

fi

if ! [ -f docker-compose.yaml ]; then

  cp -f docker-compose.example.yaml docker-compose.yaml

fi

cd ..

echo



###############################
# Yay all done
###############################

touch ~/repos/cbc-development-setup/is_installed

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