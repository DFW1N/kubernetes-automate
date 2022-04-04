#!/bin/bash



###########
# GENERAL #
###########

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
YELLOW='\033[0;33m'


location="australiaeast"
date=$(TZ=Australia/Sydney date +"%FI%H:%M")
random=$(echo | md5sum | head -c 4;)

########
# TAGS #
########

owner="Sacha Roussakis-Notter"
project="Kubernetes Advanced Training"

#############
# VARIABLES #
#############

resourceGroup="rg-sr-kubernetes-vms-001"
acrName="registryqjl3186"
aksClusterName="AKSCluster"
vmName="kubervm001"
adminName="adminuser"
password="un1c0rns@rec00l12345%"

# CREATE RESOURCE GROUP #
echo -e "${WHITE}Creating Resource Groups for ${GREEN}Kubernetes Open Hack Training${NC}." && echo
az group create --name "$resourceGroup" --location "$location" --tags "Owner"="$owner" "Project"="$project" "DateCreated"="$date" --output table && echo

# CREATE VIRTUAL MACHINE #
echo -e "${WHITE}Creating Virtual Machine ${GREEN}Kubernetes Open Hack Training${NC}." && echo
az vm create --resource-group "$resourceGroup" --assign-identity --name "$vmName" --size "Standard_DS2_v2" --admin-username "$adminName" --admin-password "$password" --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest --public-ip-sku "Standard" --public-ip-address "pip-$vmName" --tags "Owner"="$owner" "Project"="$project" "DateCreated"="$date" --output table && echo

# Add Virtual Machine Extension #
# echo -e "${WHITE}Creating Azure Container Registry ${GREEN}for the Kubernetes Open Hack Training${NC}." && echo
# az vm extension set --publisher Microsoft.Azure.ActiveDirectory --name AADSSHLoginForLinux --resource-group $resourceGroup --vm-name $vmName

# CREATE KUBERNETES CLUSTER #
echo -e "${WHITE}Creating Kubernetes Cluster for ${GREEN}Kubernetes Open Hack Training${NC}." && echo
az provider show -n Microsoft.OperationsManagement -o table
az provider show -n Microsoft.OperationalInsights -o table
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights
az aks create --resource-group $resourceGroup --name $aksClusterName --node-count 1 --enable-addons monitoring --attach-acr $acrName
az aks get-credentials --resource-group $resourceGroup --name $aksClusterName

###########
# OUTPUTS #
###########

echo -e "${WHITE}Outputting ${GREEN}Virtual Machine Public IP${NC}." && echo
vmPIP=$(az network public-ip show --resource-group "$resourceGroup" --name "pip-$vmName" --query ipAddress --output tsv) && outputVMPIP=$(echo $vmPIP | tr -d '\r')
