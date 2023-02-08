if [ $# -le 1 ]; then
  echo "Expected 2 argument: company_name and network_name"
  exit
fi
COMPANY_NAME=$1
NETWORK_NAME=$2
. $COMPANY_NAME/$NETWORK_NAME/config-context.sh
touch $COMPANY_NAME/$NETWORK_NAME/join
helm show values pharmaledger-imi/quorum-node > $qnValuesPath
if [ ! -f $TMP_FOLDER_PATH/deployment.yaml ]; then
  echo "deployment:" >>  $TMP_FOLDER_PATH/deployment.yaml
  echo "company: \"$COMPANY_NAME\"" >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(company\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
  echo "network_name: \"$NETWORK_NAME\"" >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(network_name\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
fi

helm pl-plugin --joinNetwork -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $TMP_FOLDER_PATH/deployment.yaml -o $TMP_FOLDER_PATH

helm upgrade --install --debug --wait --timeout=600s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $TMP_FOLDER_PATH/deployment.yaml --set-file use_case.joinNetwork.plugin_data_common=$TMP_FOLDER_PATH/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$TMP_FOLDER_PATH/join-network.plugin.secrets.json
enodeAddress=$(cat $qnInfoPath | grep enode_address: | awk '{print $2}' | tr -d '"')
if [ $enodeAddress == "0.0.0.0" ]; then
  echo $qnInfoPath
  cat $qnInfoPath
  qnPort=$(cat $qnInfoPath | grep enode_address_port: | awk '{print $2}' | tr -d '"')
  echo $qnPort
  enodeAddress=$(kubectl get svc | grep $qnPort | awk '{print $4}')
  enodeAddress="enode_address: \"$enodeAddress\""
  echo $enodeAddress >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(enode_address\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
  helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $TMP_FOLDER_PATH/deployment.yaml --set-file use_case.joinNetwork.plugin_data_common=$TMP_FOLDER_PATH/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$TMP_FOLDER_PATH/join-network.plugin.secrets.json
fi

echo "network_name: \"$NETWORK_NAME\"" > $TMP_FOLDER_PATH/networkName.yaml
helm pl-plugin --uploadInfo -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $TMP_FOLDER_PATH/join-network.plugin.json $TMP_FOLDER_PATH/deployment.yaml $TMP_FOLDER_PATH/networkName.yaml -o $TMP_FOLDER_PATH
