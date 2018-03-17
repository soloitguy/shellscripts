while getopts "v:s:" option
  do
    case ${option} in
    v)
      VAULTNAME=${OPTARG}
      ;;
    s)
      SECRETNAME=${OPTARG}
    esac
done

SECRETVALUE=$(az keyvault secret show --vault-name $VAULTNAME --name $SECRETNAME --query value | sed -e 's/^"//' -e 's/"$//')

echo "##vso[task.setvariable variable=metadata]$SECRETVALUE"
