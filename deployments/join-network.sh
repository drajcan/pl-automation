advancedFolder="./private-configs/epi/private/advanced"
privateFolder="./private-configs/epi/private"
qnPath="./private-configs/epi/private/advanced/quorum-node"
ethPath="./private-configs/epi/private/advanced/ethadapter"
qnValuesPath=$qnPath/my-values.yaml
ghInfoPath=$privateFolder/github.info.yaml
newNetworkService=$qnPath/new-network-service.yaml
joinNetworkInfo=$qnPath/join-network.info.yaml
qnInfoPath=$privateFolder/qn-0.info.yaml
ethInfoPath=$privateFolder/ethadapter.info.yaml
smartContractInfoPath=$advancedFolder/smartContract.info.yaml
ethValuesPath=$ethPath/my-values.yaml
ethServicePath=$ethPath/ethadapter-service.yaml

. constants.sh
mkdir $JOIN_NETWORK_DIR
helm show values pharmaledger-imi/quorum-node > $qnValuesPath
helm pl-plugin --joinNetwork -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath -o $JOIN_NETWORK_DIR

helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo --set-file use_case.joinNetwork.plugin_data_common=$JOIN_NETWORK_DIR/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$JOIN_NETWORK_DIR/join-network.plugin.secrets.json && sleep 30
echo "deployment:" >>  $JOIN_NETWORK_DIR/enode_address.yaml
enode_address=$(kubectl get svc quorum-p2p -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
deployment_entry="enode_address: \"$enode_address\""
sed -i "1 a\  ${deployment_entry}" $JOIN_NETWORK_DIR/enode_address.yaml
helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $JOIN_NETWORK_DIR/enode_address.yaml --set-file use_case.joinNetwork.plugin_data_common=$JOIN_NETWORK_DIR/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$JOIN_NETWORK_DIR/join-network.plugin.secrets.json

#helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $newNetworkService -f $qnInfoPath -f $JOIN_NETWORK_DIR/enode_address.yaml --set-file use_case.newNetwork.plugin_data_common=$JOIN_NETWORK_DIR/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$JOIN_NETWORK_DIR/new-network.plugin.secrets.json && sleep 200
#rpc_address=http://$(kubectl get svc quorum-rpc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):8545
#echo "config:" >>  $JOIN_NETWORK_DIR/rpc-address.yaml
#entry="rpcAddress: \"$rpc_address\""
#sed -i "1 a\  ${entry}" $JOIN_NETWORK_DIR/rpc-address.yaml
#
#helm pl-plugin --smartContract -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $smartContractInfoPath $JOIN_NETWORK_DIR/rpc-address.yaml -o $JOIN_NETWORK_DIR
#
#echo "smart_contract_shared_configuration:" >>  $JOIN_NETWORK_DIR/ethadapter-values.yaml
#cat $qnInfoPath | grep "network_name" >> $JOIN_NETWORK_DIR/ethadapter-values.yaml
#cat $ghInfoPath | grep "repository_name\|read_write_token" >> $JOIN_NETWORK_DIR/ethadapter-values.yaml
#cat $ethInfoPath | grep "smartContractInfoName" >>  $JOIN_NETWORK_DIR/ethadapter-values.yaml
#sed -i 's/\(smartContractInfoName\)/\  \1/' $JOIN_NETWORK_DIR/ethadapter-values.yaml
#
#helm pl-plugin --ethAdapter -i $ethValuesPath $ghInfoPath $ethServicePath $qnInfoPath $smartContractInfoPath $ethInfoPath $JOIN_NETWORK_DIR/ethadapter-values.yaml $JOIN_NETWORK_DIR/rpc-address.yaml -o $JOIN_NETWORK_DIR
#helm upgrade --install ethadapter pharmaledger-imi/ethadapter -f $ethServicePath -f $JOIN_NETWORK_DIR/ethadapter-values.yaml -f $JOIN_NETWORK_DIR/rpc-address.yaml --set-file config.smartContractInfo=$JOIN_NETWORK_DIR/eth-adapter.plugin.json,secrets.orgAccountJson=$JOIN_NETWORK_DIR/orgAccount.json
#rm -rf tmp

