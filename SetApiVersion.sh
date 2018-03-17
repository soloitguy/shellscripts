#!/bin/bash
echo "==="
echo $PWD
# echo | ls -al
# echo | cat package.json
apiVersion=$(jq -r '.version' package.json)
echo '##vso[task.setvariable variable=apiVersion;]'$apiVersion
echo apiVersion "$apiVersion"
