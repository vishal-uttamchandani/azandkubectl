#!/bin/bash

for rg in "$@"; do
        echo "deleting '$rg' resource group ..."
        az group delete -n $rg -y --no-wait
done