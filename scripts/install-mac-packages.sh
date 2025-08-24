#!/bin/bash
# Mac-specific package installation for Laravel Podium

install_packages() {
    ###############################
    # Check/Install Homebrew (Mac equivalent of apt-get)
    ###############################
    
    echo; echo-cyan 'Checking for Homebrew ...'
    echo-white
    
    if ! command -v brew &> /dev/null; then
        echo-yellow 'Homebrew not found. Installing...'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        echo-green 'Homebrew installed!'
    else
        echo-green 'Homebrew found'
    fi
    echo-white
    
    ###############################
    # Install packages via Homebrew
    ###############################
    
    echo-cyan 'Installing development packages ...'
    echo-white
    
    # Core development tools (equivalent to Linux packages)
    PACKAGES=(
        "curl"
        "jq" 
        "mysql-client"
        "p7zip"
        "node"
        "python3"
        "git"
        "trash-cli"
    )
    
    for package in "${PACKAGES[@]}"; do
        if ! brew list "$package" &> /dev/null 2>&1; then
            echo-cyan "Installing $package..."
            brew install "$package"
            echo-green "$package installed!"
        else
            echo-green "$package already installed"
        fi
    done
    
    echo-green 'Development packages installed!'; echo-white; echo
    
    ###############################
    # Docker (Auto-install Docker Desktop)
    ###############################
    
    echo-cyan 'Installing Docker Desktop ...'
    echo-white
    
    if ! command -v docker &> /dev/null; then
        echo-cyan "Docker not found. Installing Docker Desktop..."
        
        # Install Docker Desktop via Homebrew Cask
        brew install --cask docker
        
        echo-green "Docker Desktop installed!"
        echo-cyan "Starting Docker Desktop..."
        
        # Start Docker Desktop
        open -a Docker
        
        echo-yellow "Docker Desktop is starting up (this may take a minute)..."
        
        # Wait for Docker to be ready (up to 2 minutes)
        for i in {1..24}; do
            if docker info &> /dev/null 2>&1; then
                echo-green "Docker is ready!"
                break
            fi
            echo-cyan "Waiting for Docker to start... ($i/24)"
            sleep 5
        done
        
        # Final check
        if ! docker info &> /dev/null 2>&1; then
            echo-yellow "Docker Desktop is installed but still starting up."
            echo-yellow "Please wait a moment and run the installer again."
            exit 1
        fi
        
    else
        echo-green "Docker found"
        
        # Check if Docker is running
        if ! docker info &> /dev/null 2>&1; then
            echo-cyan "Starting Docker Desktop..."
            open -a Docker
            
            # Wait for Docker to start
            for i in {1..12}; do
                if docker info &> /dev/null 2>&1; then
                    break
                fi
                echo-cyan "Waiting for Docker to start... ($i/12)"
                sleep 5
            done
            
            if ! docker info &> /dev/null 2>&1; then
                echo-red "Docker failed to start. Please start Docker Desktop manually."
                exit 1
            fi
        fi
    fi
    
    echo
    docker --version
    echo
    echo-green "Docker is ready!"
    echo-white
    
    ###############################
    # Composer (PHP dependency manager)
    ###############################
    
    echo-cyan 'Installing Composer ...'
    echo-white
    
    if ! command -v composer &> /dev/null; then
        curl -sS https://getcomposer.org/installer | php
        sudo mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
        echo-green 'Composer installed!'
    else
        echo-green 'Composer found'
    fi
    
    composer --version
    echo; echo-green 'Composer ready!'; echo-white; echo
}
