. ../constants.sh
JOIN_NETWORK_DIR="$JOIN_NETWORK_DIR-$1"
if test -d $JOIN_NETWORK_DIR; then
  rm -rf $JOIN_NETWORK_DIR
fi

mkdir $JOIN_NETWORK_DIR
helm show values pharmaledger-imi/quorum-node > $qnValuesPath
helm pl-plugin --joinNetwork -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath -o $JOIN_NETWORK_DIR

helm upgrade --install --wait --timeout=600s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo --set-file use_case.joinNetwork.plugin_data_common=$JOIN_NETWORK_DIR/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$JOIN_NETWORK_DIR/join-network.plugin.secrets.json
echo "deployment:" >>  $JOIN_NETWORK_DIR/enode_address.yaml
enode_address=$(kubectl get svc quorum-p2p -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
deployment_entry="enode_address: \"$enode_address\""
sed -i "1 a\  ${deployment_entry}" $JOIN_NETWORK_DIR/enode_address.yaml
cat $qnInfoPath | grep "company" >>  $JOIN_NETWORK_DIR/enode_address.yaml
helm upgrade --install --wait --timeout=600s qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $JOIN_NETWORK_DIR/enode_address.yaml --set-file use_case.joinNetwork.plugin_data_common=$JOIN_NETWORK_DIR/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$JOIN_NETWORK_DIR/join-network.plugin.secrets.json
