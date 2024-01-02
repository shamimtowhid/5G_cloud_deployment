#! /usr/bin/env bash
 
set -e
 
# Helps clear issues of not finding Ansible package,
# perhaps due to updates running when server is first spun up
sleep 10
 
export DEBIAN_FRONTEND="noninteractive"
sudo apt update
# installing docker and docker compose
# Install dependencies
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    build-essential \
    curl \
    software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce=5:20.10.12~3-0~ubuntu-focal docker-ce-cli=5:20.10.12~3-0~ubuntu-focal containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create a symbolic link to allow running 'docker-compose' from any location
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Display installed versions
echo "Docker version:"
docker --version

echo "Docker Compose version:"
docker-compose --version

# pulling mongo image
sudo docker pull mongo

# installing gtp5g
echo ">>>>>>>>>>> INSTALLING GTP5G"
sudo apt-get update
git clone https://github.com/shamimtowhid/gtp5g.git && cd gtp5g
sudo make clean
sudo make
sleep 3
sudo make install


# cloning testbed
cd ~/
git clone https://github.com/shamimtowhid/free5gc-compose.git && cd free5gc-compose
cd base
git clone --recursive -j `nproc` https://github.com/shamimtowhid/free5gc.git
cd ..

# Build the images
sudo make all
sudo apt-get update
sudo docker-compose -f docker-compose-build.yaml build
