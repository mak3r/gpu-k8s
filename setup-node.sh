#!/bin/bash

### INSTALL DOCKER
#https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository

sudo apt-get update -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

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
