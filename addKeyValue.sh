while getopts "e:f:j:" option
  do
    case ${option} in
    e)
      RESOURCEGROUP=${OPTARG}
      ;;
    f)
      FUNCTIONNAME=${OPTARG}
      ;;
    j)
      JSONFILE=${OPTARG}
    esac
done


list=$(cat $JSONFILE | jq  .'[] | "\(.name)=\(.value)"'| tr -d '"')

for fn in $list; do
  az functionapp config appsettings set -g $RESOURCEGROUP --name $FUNCTIONNAME --settings $fn
done
