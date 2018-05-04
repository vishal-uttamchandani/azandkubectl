#!/bin/bash

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37
rg=$1
vm=$2
username=$3
openports=$4

red='\033[0;31m'
cyan='\033[0;36m'
green='\033[0;32m'
blue='\033[0;34m'
purple='\033[0;35m'
reset='\033[0m' # No Color

if [ "$#" -ne 4 ]; then
	echo "Pass the group and vm name"
	exit
fi

# Create resource group
echo -e "${cyan}creating resource group ..."
az group create -l westus -g $rg >> /dev/null
echo -e "${cyan}Using '$rg' resource group${reset}"

# Generate ssh keys
echo -e "${green}generating key pair...${reset}"

if [ -e ~/.ssh/$vm ]; then
	rm  ~/.ssh/$vm && rm ~/.ssh/$vm.pub
fi

ssh-keygen -t rsa -b 2048 -f ~/.ssh/$vm -N '' >> /dev/null
echo -e "${green}successfully generated key pair '$vm'${reset}"

# Create VM
echo -e "${purple}creating vm ...${reset}"

keyfilepath=~/.ssh/$vm.pub

echo -e "${purple}using public key at path $keyfilepath${reset}"

sleep 5 # sleep for 5 seconds for the resource group to be available
az vm create -g $rg -n $vm --image UbuntuLTS --admin-username $3 --ssh-key-value $keyfilepath >> /dev/null
echo -e "${purple}successfully created '$vm' vm${reset}"

if [ "$openports" = true ]; then
	echo -e "${cyan}opening all ports on this VM to inbound traffic${reset}"
	az vm open-port -g $rg -n $vm --port '*' --priority 100 >> /dev/null
fi

publicip=$(az vm list -g $rg --show-detail -o tsv --query "[?name == '$vm'].publicIps")

echo -e "${green}$publicip${reset}"

