#!/bin/bash

set -e


ORIG_DIR=$(pwd)

cd $(dirname "$(realpath "$0")")

cd ..

DEV_DIR=$(pwd)

source scripts/functions.sh

# Check for GUI mode flag and parse arguments
GUI_MODE=false
GIT_NAME=""
GIT_EMAIL=""
AWS_ACCESS_KEY=""
AWS_SECRET_KEY=""
AWS_REGION="us-east-1"
SKIP_AWS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --gui-mode)
            GUI_MODE=true
            shift
            ;;
        --git-name)
            GIT_NAME="$2"
            shift 2
            ;;
        --git-email)
            GIT_EMAIL="$2"
            shift 2
            ;;
        --aws-access-key)
            AWS_ACCESS_KEY="$2"
            shift 2
            ;;
        --aws-secret-key)
            AWS_SECRET_KEY="$2"
            shift 2
            ;;
        --aws-region)
            AWS_REGION="$2"
            shift 2
            ;;
        --skip-aws)
            SKIP_AWS=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Detect platform and load appropriate package installer
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="mac"
    source scripts/install-mac-packages.sh
else
    PLATFORM="linux"
    source scripts/install-linux-packages.sh
fi


# Generate stack id
STACK_ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)


# Check for and set up environment variables
if ! [ -f docker-stack/.env ]; then

	cp docker-stack/.env.example docker-stack/.env

	# Generate random numbers for B and C classes
	B_CLASS=$((RANDOM % 255 + 1))
	C_CLASS=$((RANDOM % 256))

	VPC_SUBNET="10.$B_CLASS.$C_CLASS"

	# Cross-platform sed
	podium-sed "/^#VPC_SUBNET=/c\VPC_SUBNET=$VPC_SUBNET" docker-stack/.env
	podium-sed "/^#STACK_ID=/c\STACK_ID=$STACK_ID" docker-stack/.env

else

	source docker-stack/.env

fi


# Check for and set up docker compose yaml
if ! [ -f docker-stack/docker-compose.yaml ]; then

	cp docker-stack/docker-compose.example.yaml docker-stack/docker-compose.yaml

	# Cross-platform sed for docker-compose.yaml
	podium-sed "s/STACK_ID/${STACK_ID}/g" docker-stack/docker-compose.yaml

fi


# Platform-specific permission checks (skip in GUI mode)
if [[ "$GUI_MODE" != "true" ]]; then
	if [[ "$PLATFORM" == "linux" ]]; then
		# Check and fix root perms (Linux only)
		if [[ "$(whoami)" == "root" ]]; then

			ORIG_USER=$SUDO_USER

				echo; echo-red "Do NOT run with sudo or as root!";

		echo; echo-white "Please run as regular user (you may be prompted for sudo password when needed)."; echo

		exit 1

		fi

		echo; echo

		echo-cyan 'IMPORTANT: This script must NOT be run with sudo!'

		echo; echo-white 'Running with sudo would configure Git and AWS for the root user instead of your user account.'

		echo-white 'The script will prompt for sudo password only when needed for system-level operations.'

		echo; echo

		if ! sudo -v; then

			echo; echo-red "No sudo privileges. Root access required!"; echo

			exit 1;

		fi
	elif [[ "$PLATFORM" == "mac" ]]; then
		# Mac users typically have sudo access, just verify
		if ! sudo -v; then
			echo; echo-red "Administrator privileges required for installation!"; echo
			exit 1;
		fi
	fi
else
	echo-cyan "Running in GUI mode - skipping permission checks"
	echo
fi

clear


# Platform-specific checks
if [[ "$PLATFORM" == "linux" ]]; then
	# Check for Ubuntu distribution
	if ! uname -a | grep Ubuntu > /dev/null; then
		if ! uname -a | grep pop-os > /dev/null; then
			echo-red "This script is for an Ubuntu based distribution!"
			exit 1
		fi
	fi
elif [[ "$PLATFORM" == "mac" ]]; then
	echo-cyan "Detected macOS - using Homebrew for package management"
	echo-white
fi


# Set shell aliases (bash/zsh compatible)
if [[ "$PLATFORM" == "mac" ]]; then
	# Mac typically uses zsh
	SHELL_RC="$HOME/.zshrc"
	if [[ "$SHELL" == *"bash"* ]]; then
		SHELL_RC="$HOME/.bash_profile"
	fi
else
	# Linux typically uses bash
	SHELL_RC="$HOME/.bash_aliases"
fi

# Essential development aliases for Docker-based workflow
echo; echo-cyan "IMPORTANT: Podium uses Docker-based development tools"
echo-white "This includes containerized versions of:"
echo-white "  • composer-docker - Runs Composer inside container (proper PHP environment)"
echo-white "  • art-docker      - Runs Laravel Artisan inside container"
echo-white "  • wp-docker       - Runs WP-CLI inside container"
echo-white "  • php-docker      - Runs PHP inside container"
echo-white
echo-cyan "These aliases are ESSENTIAL for Podium's workflow."
echo-yellow "Without them, you'll need to type long docker exec commands manually."
echo-white
read -p "Install essential development aliases? (strongly recommended) (y/n): " INSTALL_ALIASES

if [[ "$INSTALL_ALIASES" == "y" ]]; then
	if [[ "$PLATFORM" == "mac" ]]; then
		# For Mac, add to shell RC file
		if ! grep -q "$DEV_DIR/extras/.podium_aliases" "$SHELL_RC" 2>/dev/null; then
			echo "source $DEV_DIR/extras/.podium_aliases" >> "$SHELL_RC"
			echo-green "Essential development aliases added to $SHELL_RC"
		fi
	else
		# For Linux, use bash_aliases
		if ! [ -f ~/.bash_aliases ]; then
			echo "source $DEV_DIR/extras/.podium_aliases" > ~/.bash_aliases
		else
			if ! grep -q "$DEV_DIR/extras/.podium_aliases" ~/.bash_aliases 2>/dev/null; then
				echo "source $DEV_DIR/extras/.podium_aliases" >> ~/.bash_aliases
			fi
		fi
		echo-green "Essential development aliases added to ~/.bash_aliases"
	fi
	echo-white
	echo-cyan "IMPORTANT: Source your shell or open a new terminal session, then use these commands:"
	echo-white "  • composer-docker install    (instead of: composer install)"
	echo-white "  • art-docker migrate         (instead of: php artisan migrate)"
	echo-white "  • wp-docker plugin list      (instead of: wp plugin list)"
	echo-white "  • php-docker -v              (to check container PHP version)"
	echo-white
else
	echo-yellow "Aliases skipped - you'll need to use full docker exec commands:"
	echo-white "  docker exec -it \$(basename \$(pwd)) composer install"
	echo-white "  docker exec -it \$(basename \$(pwd)) php artisan migrate"
fi

clear

echo; echo


# Welcome screen
echo "
          WELCOME TO PODIUM DEVELOPMENT ENVIRONMENT !

Setting up your $PLATFORM development environment for PHP projects...
Leave answers blank if you do not know the info. You can re-run the
installer to enter in new info when you have it."



###############################
# Platform-specific package installation
###############################

# Call the platform-specific package installation function
install_packages



###############################
# Create ssh key
###############################
if ! [ -f ~/.ssh/id_rsa ]; then

  if ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa; then true; fi

fi



###############################
# Set up git committer info
###############################
echo; echo-cyan 'Setting up Git ...'; echo-white

if ! git config --global mergetool.keepBackup > /dev/null 2>&1; then

	git config --global mergetool.keepBackup false

fi

if ! git config --global init.defaultBranch > /dev/null 2>&1; then

	git config --global init.defaultBranch master

fi

if ! git config --global pull.rebase > /dev/null 2>&1; then

	git config --global pull.rebase false

fi

# Configure Git (use GUI-provided values or prompt)
if [[ "$GUI_MODE" == "true" ]]; then
	if [[ -n "$GIT_NAME" ]]; then
		git config --global user.name "$GIT_NAME"
		echo-cyan "Git name set to: $GIT_NAME"
	fi
	if [[ -n "$GIT_EMAIL" ]]; then
		git config --global user.email "$GIT_EMAIL"
		echo-cyan "Git email set to: $GIT_EMAIL"
	fi
else
	if ! git config user.name > /dev/null 2>&1; then

		echo-yellow -ne 'Enter your full name for Git commits: '

		echo-white -ne

		read GIT_NAME

		if ! [ -z "${GIT_NAME}" ]; then

			git config --global user.name "$GIT_NAME"

		fi

		echo

	fi

	if ! git config user.email > /dev/null 2>&1; then

		echo-yellow -ne 'Enter your email address for Git commits: '

		echo-white -ne

		read GIT_EMAIL

		if ! [ -z "${GIT_EMAIL}" ]; then

			git config --global user.email $GIT_EMAIL

		fi

		echo

	fi
fi

git --version; echo

echo-green "Git configured!"; echo-white; echo



###############################
# Set up Github authentication
###############################
echo; echo-cyan 'Setting up Github authentication ...'; echo-white

if ! gh auth status > /dev/null 2>&1; then

	echo-yellow 'Choose SSH for protocol, id_rsa.pub for SSH public key and paste an authentication token:'; echo-white

	gh auth login --hostname github.com

fi

echo; echo-green "Github authentication complete!"; echo-white; echo



###############################
# AWS
###############################

# AWS Configuration
if [[ "$SKIP_AWS" == "true" ]]; then
	echo-cyan 'Skipping AWS setup (user choice)'
	echo
elif [[ "$GUI_MODE" == "true" ]]; then
	echo-cyan 'Configuring AWS with GUI-provided settings...'

	mkdir -p ~/s3

	# Install AWS CLI if not present
	if ! aws --version > /dev/null 2>&1; then
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" > awscli-bundle.zip
		7z x awscli-bundle.zip
		rm -f awscli-bundle.zip
		sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
		sudo chmod -R o+rx /usr/local/aws-cli/v2/current/dist
		rm -fR aws
	fi

	# Configure AWS with GUI values
	if [[ -n "$AWS_ACCESS_KEY" && -n "$AWS_SECRET_KEY" ]]; then
		aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
		aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
		aws configure set default.region "$AWS_REGION"
		aws configure set default.output json
		
		# Create s3fs password file
		echo "$AWS_ACCESS_KEY:$AWS_SECRET_KEY" > ~/.passwd-s3fs
		chmod 600 ~/.passwd-s3fs
		
		echo-cyan "AWS configured with region: $AWS_REGION"
	fi
else
	echo-cyan 'Installing AWS ...'

	mkdir -p ~/s3

	echo-white

	if ! aws --version > /dev/null 2>&1; then

		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" > awscli-bundle.zip

		7z x awscli-bundle.zip

		rm -f awscli-bundle.zip

		sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

		# Bug fix
		sudo chmod -R o+rx /usr/local/aws-cli/v2/current/dist

		rm -fR aws

	fi

	if ! aws configure get default.region > /dev/null; then

		aws configure set default.region us-east-1

	fi

	if ! aws configure get default.output > /dev/null; then

		aws configure set default.output json

	fi

	aws configure

	if ! [ -f ~/.passwd-s3fs ]; then

		# Extract the AWS access key ID
		if AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id); then

			# Extract the AWS secret access key
			if AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key); then

				echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs

				chmod 600 ~/.passwd-s3fs

			fi

		fi

	fi
fi

echo

if [[ "$GUI_MODE" != "true" ]]; then
	aws --version
else
	echo-cyan 'AWS setup skipped in GUI mode'
fi

echo

echo-green "AWS installed!"

echo-white



# Docker and Node installation handled by platform-specific installers



###############################
# Hosts
###############################
echo-cyan 'Writing domain names to hosts file ...'

echo-white

while read HOST; do

	if ! cat /etc/hosts | grep "$HOST" > /dev/null 2>&1; then

		echo "$VPC_SUBNET$HOST" | sudo tee -a /etc/hosts > /dev/null

	fi

done < extras/hosts.txt 2>/dev/null || true

echo



###############################
# Yay all done
###############################

touch is_installed



###############################
# Start services
###############################

# Start services
if [[ "$GUI_MODE" == "true" ]]; then
	echo-cyan 'Setting up docker group permissions...'
	# Add user to docker group if not already there
	sudo usermod -aG docker $USER
	echo-green 'Docker group configured!'
	echo-white
	echo-yellow 'Note: Services can be started from the dashboard after installation'
	echo-white
	echo-green 'GUI installation completed successfully!'
	echo-white
else
	source "$DEV_DIR/scripts/start_services.sh"
fi



###############################
# Yay all done
###############################

cd $ORIG_DIR