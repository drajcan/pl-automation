advancedFolder="./private-configs/epi/private/advanced"
privateFolder="./private-configs/epi/private"
qnPath="./private-configs/epi/private/advanced/quorum-node"
ethPath="./private-configs/epi/private/advanced/ethadapter"
qnValuesPath=$qnPath/my-values.yaml
ghInfoPath=$privateFolder/github.info.yaml
newNetworkService=$qnPath/new-network-service.yaml
joinNetworkInfo=$qnPath/join-network.info.yaml
updatePartnersInfo=$privateFolder/update-partners.info.yaml
qnInfoPath=$privateFolder/qn-0.info.yaml
ethInfoPath=$privateFolder/ethadapter.info.yaml
smartContractInfoPath=$advancedFolder/smartContract.info.yaml
ethValuesPath=$ethPath/my-values.yaml
ethServicePath=$ethPath/ethadapter-service.yaml

. constants.sh
#helm show values pharmaledger-imi/quorum-node > $qnValuesPath
helm pl-plugin --updatePartnersInfo -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $JOIN_NETWORK_DIR/enode_address.yaml $updatePartnersInfo -o $JOIN_NETWORK_DIR
helm upgrade --install qn-0 pharmaledger-imi/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $JOIN_NETWORK_DIR/enode_address.yaml -f $updatePartnersInfo --set-file use_case.joinNetwork.plugin_data_common=$JOIN_NETWORK_DIR/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$JOIN_NETWORK_DIR/join-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=$JOIN_NETWORK_DIR/update-partners-info.plugin.json

