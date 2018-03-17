while getopts "g:" option
  do
    case ${option} in
    g)
      RESOURCEGROUP=${OPTARG}
    esac
done

INSIGHTSNAME=$(az resource list --resource-type microsoft.insights/components --resource-group $RESOURCEGROUP | jq '.[0].name' | sed -e 's/^"//' -e 's/"$//')
INSTKEY=$(az resource show --resource-type microsoft.insights/components --resource-group $RESOURCEGROUP --name $INSIGHTSNAME --query properties.InstrumentationKey | sed -e 's/^"//' -e 's/"$//')


echo "##vso[task.setvariable variable=instkey;issecret=true]$INSTKEY"
