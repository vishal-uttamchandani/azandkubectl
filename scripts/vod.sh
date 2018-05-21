#!/bin/bash

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

sshinterval=5

red='\033[1;31m'
cyan='\033[1;36m'
green='\033[1;32m'
blue='\033[1;34m'
purple='\033[1;35m'
reset='\033[0m' # No Color
yellow='\033[1;33m'

case "$#" in

1) rg=$1;vm=$1;username=$1;openallports=true;autossh=true
    ;;

5) rg=$1;vm=$2;username=3;openallports=$4;autossh=$5
    ;;

*) echo "Usage: $0 <some-name>"
    echo "Usage: $0 <rg-name> <vm-name> <user-name> <open-all-ports> <auto-ssh>"
    exit
    ;;

esac

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
keyfilepath=~/.ssh/$vm.pub
echo -e "${purple}using public key at path $keyfilepath${reset}"
echo -e "${purple}creating vm ...${reset}"


sleep 5 # sleep for 5 seconds for the resource group to be available
az vm create -g $rg -n $vm --image UbuntuLTS --admin-username $username --ssh-key-value $keyfilepath --custom-data cloud-init.yaml >> /dev/null


if [ "$openports" = true ]; then
	echo -e "${cyan}opening all ports on this VM to inbound traffic ...${reset}"
	az vm open-port -g $rg -n $vm --port '*' --priority 100 >> /dev/null
fi

publicip=$(az vm list -g $rg --show-detail -o tsv --query "[?name == '$vm'].publicIps")
#os=$(az vm show -g $rg -n $vm --query storageProfile.imageReference.offer)
#version=$(az vm show -g $rg -n $vm --query storageProfile.imageReference.sku)
#diskSize=$(az vm show -g $rg -n $vm --query storageProfile.osDisk.diskSizeGb)

echo -e "${cyan}successfully created '$vm' vm @ ${publicip}${reset}"
#echo -e "${yellow}$publicip ${os} ${version} ${diskSize}Gb${reset}"
#echo -e "${green}$publicip${reset}"
#echo "$publicip $vm $os $version $diskSize Gb" >> vms.txt 
echo "$publicip $vm" >> vms.txt 

if [ "$autossh" = true ]; then
	echo -e $"opening ssh session in $sshinternval seconds ..."
	sleep $sshinternval
	ssh -o StrictHostKeyChecking=no -i ~/.ssh/$vm $username@$publicip
fi