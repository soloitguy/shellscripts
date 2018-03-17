while getopts "d:i:s:e:" option
  do
    case ${option} in
    d)
      DBNAME=${OPTARG}
      ;;
    i)
      SERVERNAME=${OPTARG}
      ;;
    s)
      DBSECRETNAME=${OPTARG}
      ;;
    e)
      VAULTNAME=${OPTARG}
    esac
done

if [[ $DBNAME = "NA" ]]; then

  echo "Ignore DB lookup and set empty sqlconnection"
  fullString="NA"

else

  getPass=$(az keyvault secret show --vault-name $VAULTNAME --name $DBSECRETNAME --query value)
  noQuotePass=$(sed -e 's/^"//' -e 's/"$//' <<< $getPass)
  preString=$(az sql db show-connection-string --name $DBNAME --client ado.net --auth-type SqlPassword --server $SERVERNAME)
  noPortString=$(echo $preString | sed 's/,1433//')
  fullString=$(echo $noPortString | sed 's/<username>/psgadmin/' | sed "s|<password>|$noQuotePass|")

fi

echo "##vso[task.setvariable variable=sqlconnection;issecret=true]$fullString"
