NETWORKS_FOLDER=$1
NETWORK_NAME=$2
# shellcheck disable=SC2207
folderPaths=($(find $NETWORKS_FOLDER -path "*/editable/$NETWORK_NAME" | cut -f 3 -d "/"))
partners="["
for i in "${!folderPaths[@]}"; do
  partners="$partners'${folderPaths[$i]}',"
done
if  [ ! "$partners" == "[" ]; then
  partners=$(echo "$partners" | rev | cut -c2- | rev)
fi
partners="$partners]"
echo $partners