#!/bin/bash

### INSTALL DOCKER
#https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository

sudo apt-get update -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    build-essential

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y

#apt-cache madison docker-ce

sudo apt-get install -y docker-ce=17.03.2~ce-0~ubuntu-xenial

#Add the ubuntu user to the docker group for permission to run docker daemon
sudo usermod -a -G docker $USER

# Setup the apt repository for nvidia docker
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update -y

# install the nvidia docker daemon
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd

#apt-cache madison nvidia-docker2 nvidia-container-runtime

# get the nvidia drivers to install
sudo curl -o NVIDIA-Linux-x86_64-390.87.run http://us.download.nvidia.com/XFree86/Linux-x86_64/390.87/NVIDIA-Linux-x86_64-390.87.run
sudo chmod +x NVIDIA-Linux-x86_64-390.87.run
