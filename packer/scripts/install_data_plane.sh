#! /usr/bin/env bash
 
set -e
 
# Helps clear issues of not finding Ansible package,
# perhaps due to updates running when server is first spun up
sleep 10
 
export DEBIAN_FRONTEND="noninteractive"
sudo apt -y update


uname -r

# installing GO
wget https://dl.google.com/go/go1.18.10.linux-amd64.tar.gz
sudo tar -C /usr/local -zxvf go1.18.10.linux-amd64.tar.gz
mkdir -p ~/go/{bin,pkg,src}
# The following assume that your shell is bash:
echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
echo 'export GOROOT=/usr/local/go' >> $HOME/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> $HOME/.bashrc
echo 'export GO111MODULE=auto' >> $HOME/.bashrc

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
export GO111MODULE=auto

echo $GOPATH
echo $GOROOT
echo $PATH
echo $HOME
echo $GO111MODULE

# user-plane supporting packages
sudo apt -y update
sudo apt -y install git gcc g++ cmake autoconf libtool pkg-config libmnl-dev libyaml-dev

# installing gtp5g
git clone -b v0.8.6 https://github.com/free5gc/gtp5g.git
cd gtp5g
make
sudo make install


# cloning free5gc repo
cd ~
git clone --recursive -b v3.4.1 -j `nproc` https://github.com/free5gc/free5gc.git
cd ~/free5gc
make upf

# installing wireguard
sudo apt -y install wireguard
