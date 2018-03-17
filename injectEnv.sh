while getopts e: option
  do
    case "${option}"
    in
    e) ENVIRONMENT=${OPTARG};;
    esac
done

sed -i -e "s|\(<\/head>\)|<script>window.environment=\"$ENVIRONMENT\"\<\/script><\/head>|g" /usr/share/nginx/html/index.html
