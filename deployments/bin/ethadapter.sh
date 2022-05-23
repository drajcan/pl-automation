. ../constants.sh

if [ $# == 1 ]; then
  NEW_NETWORK_DIR="$JOIN_NETWORK_DIR-$1"
fi

echo "smart_contract_shared_configuration:" >>  $NEW_NETWORK_DIR/ethadapter-values.yaml
cat $qnInfoPath | grep "network_name" >> $NEW_NETWORK_DIR/ethadapter-values.yaml
cat $ghInfoPath | grep "repository_name\|read_write_token" >> $NEW_NETWORK_DIR/ethadapter-values.yaml
cat $ethInfoPath | grep "smartContractInfoName" >>  $NEW_NETWORK_DIR/ethadapter-values.yaml
sed -i 's/\(smartContractInfoName\)/\  \1/' $NEW_NETWORK_DIR/ethadapter-values.yaml

helm pl-plugin --ethAdapter -i $ethValuesPath $ghInfoPath $ethServicePath $qnInfoPath $smartContractInfoPath $ethInfoPath $NEW_NETWORK_DIR/ethadapter-values.yaml $NEW_NETWORK_DIR/rpc-address.yaml -o $NEW_NETWORK_DIR
helm upgrade --install --wait --timeout=600s ethadapter pharmaledger-imi/ethadapter -f $ethServicePath -f $NEW_NETWORK_DIR/ethadapter-values.yaml -f $NEW_NETWORK_DIR/rpc-address.yaml --set-file config.smartContractInfo=$NEW_NETWORK_DIR/eth-adapter.plugin.json,secrets.orgAccountJson=$NEW_NETWORK_DIR/orgAccount.json
