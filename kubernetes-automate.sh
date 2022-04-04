#!/bin/bash

# ======================================================================================================================== #
#                                                                                                                          #
#  Project:        Kubernetes Advanced Training                                                                            #
#  Author:         Sacha Roussakis-Notter                                                                                  #
#  Creation Date:  Monday, 4th April 2022                                                                                  #
#  File Name:      kubernetes-automate.sh                                                                                  #
#                                                                                                                          #
#   Copyright (c) 2022, Sacha Roussakis-Notter                                                                             #
#                                                                                                                          #
#   Date              By                     Comments                                                                      #
#   ---------         ---------------        ------------------------------------------------------------------------      #
#                                                                                                                          #
# ======================================================================================================================== #


###########
# GENERAL #
###########

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
YELLOW='\033[0;33m'

################
# CONFIGURE VM #
################

echo -e "${WHITE}Installing ${GREEN}Docker${NC}." && echo
sudo apt update && sudo apt upgrade -y;
sudo apt install docker.io -y;

echo -e "${WHITE}Checking ${GREEN}Docker Version${NC}." && echo
docker --version

echo -e "${WHITE}Start and Enable ${GREEN}Docker${NC}." && echo
sudo systemctl enable docker;
sudo systemctl start docker;


echo -e "${WHITE}Installing ${GREEN}Azure CLI${NC}." && echo
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

echo -e "${WHITE}Installing ${GREEN}Helm${NC}." && echo
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo -e "${WHITE}Install ${GREEN}vscode${NC}." && echo
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https -y
sudo apt update -y
sudo apt install code -y

echo -e "${WHITE}Installing ${GREEN}Kubernetes${NC}." && echo
sudo apt -y install curl apt-transport-https -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo -e "${WHITE}Checking ${GREEN}Kubernetes Version${NC}." && echo
kubectl version --client && kubeadm version

echo -e "${WHITE}Kubernetes Deployment ${GREEN}Swap${NC}." && echo
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

echo -e "${WHITE} Assign Unique Hostname for ${GREEN}Each Server Node${NC}." && echo
sudo hostnamectl set-hostname master-node
sudo hostnamectl set-hostname w1

echo -e "${WHITE}Initialize Kubernetes on ${GREEN}Master Node${NC}." && echo

echo -e "${WHITE}Initialize Pulling SQL Server ${GREEN}Docker Image${NC}." && echo
sudo docker pull mcr.microsoft.com/mssql/server:2017-latest

echo -e "${WHITE}Clone Microsoft OpenHack ${GREEN}Container Artifacts${NC}." && echo
git clone https://github.com/Microsoft-OpenHack/containers_artifacts.git

echo -e "${WHITE}Install ${GREEN}kubectx + kubens${NC}." && echo
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

## docker ps -q -a | xargs docker rm -f
## docker rmi -f $(docker images | grep "^<none>" | awk '{print $3}')
