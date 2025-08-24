#!/bin/bash
# Linux-specific package installation for Laravel Podium

install_packages() {
    ###############################
    # Initial update and package installations
    ###############################
    
    echo; echo-cyan 'Updating and installing initial packages ...'
    echo-white
    
    sudo apt-get update -y
    sudo apt-get -y install ca-certificates curl python3-pip python3-venv figlet mariadb-client apt-transport-https gnupg lsb-release s3fs acl unzip jq p7zip-full p7zip-rar trash-cli
    
    echo-green 'Packages installed!'; echo-white; echo
    
    ###############################
    # Docker
    ###############################
    
    echo-cyan 'Installing Docker ...'
    echo-white
    
    for PKG in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        if sudo apt-get -y purge $PKG; then true; fi
    done
    
    if ! [ -f /etc/apt/sources.list.d/docker.list ]; then
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update -y -q
    fi
    
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    echo
    docker --version
    echo
    echo-green "Docker installed and user added to docker group!"
    echo-yellow "Note: You may need to log out and back in for docker group changes to take effect"
    echo-white
    
    ###############################
    # NPM / Nodejs
    ###############################
    
    echo-cyan 'Installing Node / NPM ...'
    echo-white
    
    if ! command -v node > /dev/null 2>&1; then
        # Install nvm (Node Version Manager)
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        
        # Explicitly source nvm to make it available in the script
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Install Node.js using nvm
        nvm install 20
        
        # Verify Node.js installation
        node -v
    fi
    
    npm -v
    echo; echo-green 'Node / NPM installed!'; echo-white; echo
    
    ###############################
    # Clean up apt get stuff
    ###############################
    echo-cyan 'Cleaning up ...'
    echo-white
    
    # Wait for any running apt processes to complete
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo-yellow 'Waiting for other package operations to complete...'
        sleep 2
    done
    
    sudo apt-get -y -q autoremove
    echo
}
