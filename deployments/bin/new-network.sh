. ../constants.sh
if test -d $NEW_NETWORK_DIR; then
  rm -rf $NEW_NETWORK_DIR
fi

mkdir $NEW_NETWORK_DIR
helm show values pharmaledger-imi/quorum-node > $qnValuesPath

helm pl-plugin --newNetwork -i $qnValuesPath $ghInfoPath $qnInfoPath $newNetworkService -o $NEW_NETWORK_DIR

helm upgrade --install --wait --timeout=600s  qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $newNetworkService -f $qnInfoPath -f $ghInfoPath --set-file use_case.newNetwork.plugin_data_common=$NEW_NETWORK_DIR/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$NEW_NETWORK_DIR/new-network.plugin.secrets.json
echo "deployment:" >>  $NEW_NETWORK_DIR/enode_address.yaml
enode_address=$(kubectl get svc quorum-p2p -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
deployment_entry="enode_address: \"$enode_address\""
sed -i "1 a\  ${deployment_entry}" $NEW_NETWORK_DIR/enode_address.yaml
cat $qnInfoPath | grep "company" >>  $NEW_NETWORK_DIR/enode_address.yaml

helm upgrade --install --wait --timeout=600s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $newNetworkService -f $qnInfoPath -f $NEW_NETWORK_DIR/enode_address.yaml --set-file use_case.newNetwork.plugin_data_common=$NEW_NETWORK_DIR/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$NEW_NETWORK_DIR/new-network.plugin.secrets.json

#rpc_address=http://$(kubectl get svc quorum-rpc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8545
rpc_address=http://$(kubectl get svc quorum-rpc | grep quorum-rpc | awk '{print $3}'):8545
echo "config:" >>  $NEW_NETWORK_DIR/rpc-address.yaml
entry="rpcAddress: \"$rpc_address\""
sed -i "1 a\  ${entry}" $NEW_NETWORK_DIR/rpc-address.yaml

helm pl-plugin --smartContract -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $smartContractInfoPath $NEW_NETWORK_DIR/rpc-address.yaml -o $NEW_NETWORK_DIR