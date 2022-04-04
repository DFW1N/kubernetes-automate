#!/bin/bash

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

echo -e "${WHITE}Installing ${GREEN}Kubernetes${NC}." && echo
sudo apt -y install curl apt-transport-https -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
echo -e "${WHITE}Checking ${GREEN}Kubernetes Version${NC}." && echo
kubectl version --client && kubeadm version
echo -e "${WHITE}Disable ${GREEN}Swap${NC}." && echo
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
echo -e "${WHITE} Unique Hostname for ${GREEN}Each Server Node${NC}." && echo
sudo hostnamectl set-hostname master-node
sudo hostnamectl set-hostname w1

## docker ps -q -a | xargs docker rm -f

## docker rmi -f $(docker images | grep "^<none>" | awk '{print $3}')
