tempfile="$(mktemp)"
trap "rm -rf \"${tempfile}\"" EXIT

jq ".properties.masterProfile.vnetSubnetId = \"/subscriptions/77065df4-0038-4f85-b179-f69651fe8137/resourceGroups/its-dev-app-k8s/providers/Microsoft.Network/virtualNetworks/its-dev-k8s-vnet/subnets/its-dev-k8s-subnet\"" devApik8s.json > $tempfile && mv $tempfile devApik8s.json

indx=0
for poolname in `jq -r '.properties.agentPoolProfiles[].name' "devApik8s.json"`; do
  jq ".properties.agentPoolProfiles[$indx].vnetSubnetId = \"/subscriptions/77065df4-0038-4f85-b179-f69651fe8137/resourceGroups/its-dev-app-k8s/providers/Microsoft.Network/virtualNetworks/its-dev-k8s-vnet/subnets/its-dev-k8s-subnet\"" devApik8s.json > $tempfile && mv $tempfile devApik8s.json
  indx=$((indx+1))
done
