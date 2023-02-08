if [ $# -le 1 ]; then
  echo "Expected 2 argument: company_name and network_name"
  exit
fi
COMPANY_NAME=$1
NETWORK_NAME=$2
. $COMPANY_NAME/$NETWORK_NAME/config-context.sh

helm show values pharmaledger-imi/quorum-node > $qnValuesPath
if [ ! -d $TMP_FOLDER_PATH ]; then
  mkdir $TMP_FOLDER_PATH
fi
if [ ! -f $TMP_FOLDER_PATH/deployment.yaml ]; then
  echo "deployment:" >>  $TMP_FOLDER_PATH/deployment.yaml
  echo "company: \"$COMPANY_NAME\"" >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(company\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
  echo "network_name: \"$NETWORK_NAME\"" >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(network_name\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
fi

helm pl-plugin --newNetwork -i $qnValuesPath $ghInfoPath $qnInfoPath $newNetworkService $TMP_FOLDER_PATH/deployment.yaml -o $TMP_FOLDER_PATH

helm upgrade --install --debug --wait --timeout=300s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $newNetworkService -f $qnInfoPath -f $ghInfoPath -f $TMP_FOLDER_PATH/deployment.yaml --set-file use_case.newNetwork.plugin_data_common=$TMP_FOLDER_PATH/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$TMP_FOLDER_PATH/new-network.plugin.secrets.json

enodeAddress=$(cat $qnInfoPath | grep enode_address: | awk '{print $2}' | tr -d '"')
if [ $enodeAddress == "0.0.0.0" ]; then
  qnPort=$(cat $qnInfoPath | grep enode_address_port: | awk '{print $2}' | tr -d '"')
  enodeAddress=$(kubectl get svc | grep $qnPort | awk '{print $4}')
  enodeAddress="enode_address: \"$enodeAddress\""
  echo $enodeAddress >>  $TMP_FOLDER_PATH/deployment.yaml
  sed -i 's/\(enode_address\)/\  \1/' $TMP_FOLDER_PATH/deployment.yaml
  helm upgrade --install --wait --timeout=300s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $newNetworkService -f $qnInfoPath -f $TMP_FOLDER_PATH/deployment.yaml --set-file use_case.newNetwork.plugin_data_common=$TMP_FOLDER_PATH/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$TMP_FOLDER_PATH/new-network.plugin.secrets.json
fi

echo "network_name: \"$NETWORK_NAME\"" > $TMP_FOLDER_PATH/networkName.yaml
if [ ! -f $TMP_FOLDER_PATH/rpc-address.yaml ]; then
  rpc_address=http://$(kubectl get svc | grep 8545 | awk '{print $3}'):8545
  echo "config:" >>  $TMP_FOLDER_PATH/rpc-address.yaml
  entry="rpcAddress: \"$rpc_address\""
  echo $entry >> $TMP_FOLDER_PATH/rpc-address.yaml
  sed -i 's/\(rpcAddress\)/\  \1/' $TMP_FOLDER_PATH/rpc-address.yaml
fi
helm pl-plugin --smartContract -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $smartContractInfoPath $TMP_FOLDER_PATH/networkName.yaml -o $TMP_FOLDER_PATH
helm pl-plugin --uploadInfo -i $qnValuesPath $newNetworkService $ghInfoPath $qnInfoPath $TMP_FOLDER_PATH/new-network.plugin.json $TMP_FOLDER_PATH/deployment.yaml $TMP_FOLDER_PATH/networkName.yaml -o $TMP_FOLDER_PATH
