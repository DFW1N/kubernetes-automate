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
vmName="kubervm001"
adminName="adminuser"
password="un1c0rns@rec00l12345%"

# CREATE RESOURCE GROUP #
echo -e "${WHITE}Creating Resource Groups for ${GREEN}Kubernetes Open Hack Training${NC}." && echo
az group create --name "$resourceGroup" --location "$location" --tags "Owner"="$owner" "Project"="$project" "DateCreated"="$date" --output table && echo

# CREATE VIRTUAL MACHINE #
echo -e "${WHITE}Creating Virtual Machine ${GREEN}Kubernetes Open Hack Training${NC}." && echo
az vm create --resource-group "$resourceGroup" --assign-identity --name "$vmName" --size "Standard_DS2_v2" --admin-username "$adminName" --admin-password "$password" --image Canonical:0001-com-ubuntu-server-focal:20_04-lts:latest --public-ip-sku "Standard" --public-ip-address "pip-$vmName" --tags "Owner"="$owner" "Project"="$project" "DateCreated"="$date" --output table && echo

# Create Azure Container Registry #
#echo -e "${WHITE}Creating Azure Container Registry ${GREEN}for the Kubernetes Open Hack Training${NC}." && echo

az vm extension set --publisher Microsoft.Azure.ActiveDirectory --name AADSSHLoginForLinux --resource-group $resourceGroup --vm-name $vmName

###########
# OUTPUTS #
###########

echo -e "${WHITE}Outputting ${GREEN}Virtual Machine Public IP${NC}." && echo
vmPIP=$(az network public-ip show --resource-group "$resourceGroup" --name "pip-$vmName" --query ipAddress --output tsv) && outputVMPIP=$(echo $vmPIP | tr -d '\r')
