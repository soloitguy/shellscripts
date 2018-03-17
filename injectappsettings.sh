#!/bin/bash
# injectSettings.sh
#


while getopts "c:i:s:e:m:p:k:" option
  do
    case ${option} in
    c)
      CONNECTION=${OPTARG}
      ;;
    i)
      INSTRUMENTATION=${OPTARG}
      ;;
    s)
      SECRETNAME=${OPTARG}
      ;;
    e)
      ENVIRONMENTNAME=${OPTARG}
      ;;
    m)
      METADATA=${OPTARG}
      ;;
    p)
      PMESSAGE=${OPTARG}
      ;;
    k)
      SMESSAGE=${OPTARG}
      ;;
    esac
done
export CONNSTRING="$CONNECTION"
export INSTKEY="$INSTRUMENTATION"
export MA="$METADATA"
export PM="$PMESSAGE"
export SM="$SMESSAGE"


jq '.Abc.Absg.ConnectionStrings.DefaultConnection = env.CONNSTRING' ./appsettings.json > temp.json && mv temp.json appsettings.json
jq '.Abc.Absg.ApplicationInsights.InstrumentationKey = env.INSTKEY' appsettings.json > temp.json && mv temp.json appsettings.json
jq '.Abc.Absg.Jwt.MetadataAddress= env.MA' appsettings.json > temp.json && mv temp.json appsettings.json
jq '.Abc.Absg.Messaging.ConnectionString= env.PM' appsettings.json > temp.json && mv temp.json appsettings.json
jq '.Abc.Absg.Messaging.SecondaryConnectionString= env.SM' appsettings.json > temp.json && mv temp.json appsettings.json

newsecret=$(kubectl get secret $SECRETNAME --ignore-not-found)
echo "Checking if the secret exists..."

if [[ $newsecret = "" ]]; then
  echo "Secret does not exist..."
  echo "Creating secret $SECRETNAME"
  kubectl create secret generic $SECRETNAME --from-file=appsettings.json ;
else
  echo "$SECRETNAME already exists..."
  echo "Deleting $SECRETNAME..."
  kubectl delete secret $SECRETNAME
  echo "Creating secret $SECRETNAME..."
  kubectl create secret generic $SECRETNAME --from-file=appsettings.json;
fi
