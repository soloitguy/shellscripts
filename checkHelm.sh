while getopts "n:a:" option
  do
    case ${option} in
    n)
      APPNAME=${OPTARG}
      ;;
    a)
      INSTARGS=${OPTARG}
      ;;
    esac
  done

HELMLIST=$(helm list -q)

for ln in $HELMLIST; do
  if [ $ln = "$APPNAME" ]; then
    APPEXISTS=true;
    echo "$APPNAME exists."
    break
  else
    echo "Not this one."
  fi
done

if [[ $APPEXISTS = true ]]; then
   echo "UPGRADING $APPNAME with arguments: $INSTARGS"
   helm upgrade $APPNAME $INSTARGS
else
   echo "INSTALLING $APPNAME with arguments: $INSTARGS"
   helm install --name $APPNAME $INSTARGS
fi
