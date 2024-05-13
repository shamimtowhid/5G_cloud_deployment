#! /usr/bin/env bash
 
set -e
 
# Helps clear issues of not finding Ansible package,
# perhaps due to updates running when server is first spun up
sleep 10
 
export DEBIAN_FRONTEND="noninteractive"
sudo apt -y update
# installing docker and docker compose
# Install dependencies
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    build-essential \
    curl \
    software-properties-common

cd ~
git clone https://github.com/aligungr/UERANSIM
cd UERANSIM
git checkout 3a96298

sudo apt update -y
sudo apt upgrade -y

sudo apt install make -y
sudo apt install g++ -y
sudo apt install libsctp-dev lksctp-tools -y
sudo apt install iproute2 -y
sudo snap install cmake --classic

cd ~/UERANSIM
make

# install wireguard
sudo apt -y install wireguard
