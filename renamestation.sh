while getopts e: option
  do
    case "${option}"
    in
    e) ENVIRONMENT=${OPTARG};;
    esac
done

for filename in *.exe; do
  mv $filename $ENVIRONMENT-$filename;
done

for filename in *.nupkg; do
  mv $filename $ENVIRONMENT-$filename;
done
