. ../constants.sh
if test -d $NEW_NETWORK_DIR; then
  rm -rf $NEW_NETWORK_DIR
fi

mkdir $NEW_NETWORK_DIR
helm show values pharmaledger-imi/quorum-node > $qnValuesPath

helm pl-plugin --newNetwork -i $qnValuesPath $ghInfoPath $qnInfoPath $newNetworkService -o $NEW_NETWORK_DIR

helm upgrade --install  qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $newNetworkService -f $qnInfoPath -f $ghInfoPath --set-file use_case.newNetwork.plugin_data_common=$NEW_NETWORK_DIR/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$NEW_NETWORK_DIR/new-network.plugin.secrets.json && sleep 30
echo "deployment:" >>  $NEW_NETWORK_DIR/enode_address.yaml
enode_address=$(kubectl get svc quorum-p2p -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
deployment_entry="enode_address: \"$enode_address\""
sed -i "1 a\  ${deployment_entry}" $NEW_NETWORK_DIR/enode_address.yaml
cat $qnInfoPath | grep "company" >>  $NEW_NETWORK_DIR/enode_address.yaml

helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $newNetworkService -f $qnInfoPath -f $NEW_NETWORK_DIR/enode_address.yaml --set-file use_case.newNetwork.plugin_data_common=$NEW_NETWORK_DIR/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$NEW_NETWORK_DIR/new-network.plugin.secrets.json && sleep 200

#rpc_address=http://$(kubectl get svc quorum-rpc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8545
rpc_address=http://$(kubectl get svc quorum-rpc | grep quorum-rpc | awk '{print $3}'):8545
echo "config:" >>  $NEW_NETWORK_DIR/rpc-address.yaml
entry="rpcAddress: \"$rpc_address\""
sed -i "1 a\  ${entry}" $NEW_NETWORK_DIR/rpc-address.yaml

helm pl-plugin --smartContract -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $smartContractInfoPath $NEW_NETWORK_DIR/rpc-address.yaml -o $NEW_NETWORK_DIR

echo "smart_contract_shared_configuration:" >>  $NEW_NETWORK_DIR/ethadapter-values.yaml
cat $qnInfoPath | grep "network_name" >> $NEW_NETWORK_DIR/ethadapter-values.yaml
cat $ghInfoPath | grep "repository_name\|read_write_token" >> $NEW_NETWORK_DIR/ethadapter-values.yaml
cat $ethInfoPath | grep "smartContractInfoName" >>  $NEW_NETWORK_DIR/ethadapter-values.yaml
sed -i 's/\(smartContractInfoName\)/\  \1/' $NEW_NETWORK_DIR/ethadapter-values.yaml

helm pl-plugin --ethAdapter -i $ethValuesPath $ghInfoPath $ethServicePath $qnInfoPath $smartContractInfoPath $ethInfoPath $NEW_NETWORK_DIR/ethadapter-values.yaml $NEW_NETWORK_DIR/rpc-address.yaml -o $NEW_NETWORK_DIR
helm upgrade --install ethadapter pharmaledger-imi/ethadapter -f $ethServicePath -f $NEW_NETWORK_DIR/ethadapter-values.yaml -f $NEW_NETWORK_DIR/rpc-address.yaml --set-file config.smartContractInfo=$NEW_NETWORK_DIR/eth-adapter.plugin.json,secrets.orgAccountJson=$NEW_NETWORK_DIR/orgAccount.json
