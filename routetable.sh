rt=$(az network route-table list -g poc-acse | jq -r '.[].id')

az network vnet subnet update -n its-dev-k8s-subnet -g poc-acse --vnet-name its-dev-k8s-vnet --route-table $rt
