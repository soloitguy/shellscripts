while getopts e: option
  do
    case "${option}"
    in
    e) ENVIRONMENT=${OPTARG};;
    esac
done

oldestVersion=$(curl -s 'http://ers-nim-client-internal/api/version?channel='$ENVIRONMENT'' | jq '.|=sort_by(.createdAt)' | jq .'[0]'.name | tr -d '"')

echo 'Deleting' $oldestVersion

curl -X "DELETE" 'http://ers-nim-client-internal/api/version/'$oldestVersion''
