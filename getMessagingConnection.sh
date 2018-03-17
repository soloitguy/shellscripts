while getopts "e:" option
  do
    case ${option} in
    e)
      ENVIRONMENT=${OPTARG}
    esac
done


if [[ $ENVIRONMENT = "dev" ]]; then
  VAULTNAME="psg-cp-dev-arm-keyvault"
elif [[ $ENVIRONMENT = "test" ]]; then
  VAULTNAME="psg-cp-test-arm-keyvault"
elif [[ $ENVIRONMENT = "stage" ]]; then
  VAULTNAME="psg-cp-stge-arm-keyvault"
elif [[ $ENVIRONMENT = "prod" ]]; then
  VAULTNAME="psg-cp-prod-arm-keyvault"
else
  echo "Invalid Enviroment Name, please use dev, test, stage or prod."
  exit 1
fi

primaryQuoted=$(az keyvault secret show --vault-name $VAULTNAME --name primaryMessagingConnection --query value)
secondaryQuoted=$(az keyvault secret show --vault-name $VAULTNAME --name secondaryMessagingConnection --query value)
noQuotePrimary=$(sed -e 's/^"//' -e 's/"$//' <<< $primaryQuoted )
noQuoteSecondary=$(sed -e 's/^"//' -e 's/"$//' <<< $secondaryQuoted )

echo "##vso[task.setvariable variable=primaryMessaging;issecret=true]$noQuotePrimary"
echo "##vso[task.setvariable variable=secondaryMessaging;issecret=true]$noQuoteSecondary"
