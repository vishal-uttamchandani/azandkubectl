#pattern=$1

# for rg in $(az group list -o tsv --query "[?contains(name, '$pattern')].name"); do
#         echo "deleting resource group $rg"
#         az group delete -y -n $rg --no-wait
# done