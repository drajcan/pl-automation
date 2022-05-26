if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh

echo "smart_contract_shared_configuration:" >>  $COMPANY_NAME/tmp/ethadapter-values.yaml
cat $ghInfoPath | grep "repository_name\|read_write_token" >> $COMPANY_NAME/tmp/ethadapter-values.yaml
cat $ethInfoPath | grep "smartContractInfoName" >>  $COMPANY_NAME/tmp/ethadapter-values.yaml
sed -i 's/\(smartContractInfoName\)/\  \1/' $COMPANY_NAME/tmp/ethadapter-values.yaml
echo "network_name: \"$NETWORK_NAME\"" >> $COMPANY_NAME/tmp/ethadapter-values.yaml
sed -i 's/\(network_name\)/\  \1/' $COMPANY_NAME/tmp/ethadapter-values.yaml

helm pl-plugin --ethAdapter -i $ethValuesPath $ghInfoPath $ethServicePath $qnInfoPath $smartContractInfoPath $ethInfoPath $COMPANY_NAME/tmp/ethadapter-values.yaml $COMPANY_NAME/tmp/rpc-address.yaml -o $COMPANY_NAME/tmp
helm upgrade --install --wait --timeout=600s ethadapter pharmaledger-imi/ethadapter -f $ethServicePath -f $COMPANY_NAME/tmp/ethadapter-values.yaml -f $COMPANY_NAME/tmp/rpc-address.yaml --set-file config.smartContractInfo=$COMPANY_NAME/tmp/eth-adapter.plugin.json,secrets.orgAccountJson=$COMPANY_NAME/tmp/orgAccount.json
