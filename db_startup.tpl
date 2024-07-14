#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo groupadd docker
sudo usermod -aG docker $USER
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo az login --identity -u ${uid_id} &&
sudo az acr login --name cfptestregistry007 &&
sudo docker pull cfptestregistry007.azurecr.io/cfp_db:latest
sudo docker run --network host -e POSTGRES_HOST_AUTH_METHOD=trust -d cfptestregistry007.azurecr.io/cfp_db:latest