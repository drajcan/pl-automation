if [ $# -le 1 ]; then
  echo "Expected 2 argument: company_name and network_name"
  exit
fi
COMPANY_NAME=$1
NETWORK_NAME=$2
. $COMPANY_NAME/$NETWORK_NAME/config-context.sh

helm show values pharmaledger-imi/quorum-node > $qnValuesPath

if [ ! -f $TMP_FOLDER_PATH/deployment.yaml ]; then
  echo "deployment:" >>  $TMP_FOLDER_PATH/deployment.yaml
  echo "company: \"$COMPANY_NAME\"" >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(company\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
  echo "network_name: \"$NETWORK_NAME\"" >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(network_name\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
fi

echo "network_name: \"$NETWORK_NAME\"" > $TMP_FOLDER_PATH/networkName.yaml

if test -f $COMPANY_NAME/$NETWORK_NAME/join; then
  helm pl-plugin --updatePartnersInfo -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $TMP_FOLDER_PATH/deployment.yaml $TMP_FOLDER_PATH/networkName.yaml $updatePartnersInfo -o $TMP_FOLDER_PATH
  helm upgrade --install --debug --wait --timeout=600s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $TMP_FOLDER_PATH/deployment.yaml -f $TMP_FOLDER_PATH/networkName.yaml -f $updatePartnersInfo --set-file use_case.joinNetwork.plugin_data_common=$TMP_FOLDER_PATH/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$TMP_FOLDER_PATH/join-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=$TMP_FOLDER_PATH/update-partners-info.plugin.json
#  rm -rf $TMP_FOLDER_PATH
else
  helm pl-plugin --updatePartnersInfo -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $updatePartnersInfo $TMP_FOLDER_PATH/deployment.yaml $TMP_FOLDER_PATH/networkName.yaml -o $TMP_FOLDER_PATH
  helm upgrade --install --debug --wait --timeout=600s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $newNetworkService -f $TMP_FOLDER_PATH/deployment.yaml -f $TMP_FOLDER_PATH/networkName.yaml -f $updatePartnersInfo --set-file use_case.newNetwork.plugin_data_common=$TMP_FOLDER_PATH/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$TMP_FOLDER_PATH/new-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=$TMP_FOLDER_PATH/update-partners-info.plugin.json
#  rm -rf $TMP_FOLDER_PATH
fi