stationversion=$(jq -r '.version' package.json)
echo '##vso[task.setvariable variable=stationversion;]'$stationversion
