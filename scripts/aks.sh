#!/bin/bash

red='\033[1;31m'
cyan='\033[0;36m'
green='\033[0;32m'
blue='\033[1;34m'
purple='\033[1;35m'
reset='\033[0m' # No Color
yellow='\033[1;33m'

# name=$1
# nodes=$2
# installkubectl=$3

case "$#" in

1) name=$1;nodes=1;installkubectl=true
    ;;

2) name=$1;nodes=$2;installkubectl=true
    ;;

3) name=$1;nodes=$2;installkubectl=$3
    ;;

*) echo "Usage: $0 <name>"
    echo "Usage: $0 <name> <node-count>"
    echo "Usage: $0 <name> <node-count> <install-kubectl>"
    ;;

esac

echo -e "${cyan}creating resource group ...${reset}"
az group create -l centralus -n $name >> /dev/null

echo -e "${purple}creating kubernetes cluster with $nodes node(s) ...${reset}"
az aks create -g $name -n $name --node-count $nodes --generate-ssh-keys >> /dev/null

if [ "$installkubectl" = true ]; then
    echo -e "${green}installing kubectl ...${reset}"
    az aks install-cli >> /dev/null
fi

echo -e "${yellow}setting cluster context in kube config ...${reset}"
az aks get-credentials -g $name -n $name >> /dev/null

echo -e "${cyan}"
kubectl get node
echo -e "${reset}"

