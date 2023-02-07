if [ $# -le 1 ]; then
  echo "Expected 2 argument: company_name and network_name"
  exit
fi
COMPANY_NAME=$1
NETWORK_NAME=$2
. $COMPANY_NAME/$NETWORK_NAME/config-context.sh

if [ ! -d $TMP_FOLDER_PATH ]; then
  mkdir $TMP_FOLDER_PATH
fi

if test -f $TMP_FOLDER_PATH/ethadapter-values.yaml; then
  rm -f $TMP_FOLDER_PATH/ethadapter-values.yaml
fi

helm show values pharmaledger-imi/ethadapter > $ethValuesPath
if [ ! -f $TMP_FOLDER_PATH/ethadapter-values.yaml ]; then
  echo "smart_contract_shared_configuration:" >>  $TMP_FOLDER_PATH/ethadapter-values.yaml
  cat $ghInfoPath | grep "repository_name\|read_write_token" >> $TMP_FOLDER_PATH/ethadapter-values.yaml
  cat $ethInfoPath | grep "smartContractInfoName" >>  $TMP_FOLDER_PATH/ethadapter-values.yaml
  sed -i 's/\(smartContractInfoName\)/\  \1/' $TMP_FOLDER_PATH/ethadapter-values.yaml
fi

ls -la $TMP_FOLDER_PATH

if [ ! -f $TMP_FOLDER_PATH/rpc-address.yaml ]; then
  validatorName=$(kubectl get svc | grep 8545 | awk '{print $1}')
  validatorName=($validatorName)
  rpc_address=http://$validatorName:8545
  echo "config:" >>  $TMP_FOLDER_PATH/rpc-address.yaml
  entry="rpcAddress: \"$rpc_address\""
  sed -i "1 a\  ${entry}" $TMP_FOLDER_PATH/rpc-address.yaml
fi

echo "network_name: \"$NETWORK_NAME\"" > $TMP_FOLDER_PATH/networkName.yaml

helm pl-plugin --ethAdapter -i $ethValuesPath $ghInfoPath $ethServicePath $qnInfoPath $smartContractInfoPath $ethInfoPath $ethInfoPath $TMP_FOLDER_PATH/ethadapter-values.yaml $TMP_FOLDER_PATH/rpc-address.yaml $TMP_FOLDER_PATH/networkName.yaml -o $TMP_FOLDER_PATH
helm upgrade --install --debug --wait --timeout=600s ethadapter pharmaledger-imi/ethadapter -f $ethServicePath -f $ethInfoPath -f $TMP_FOLDER_PATH/ethadapter-values.yaml -f $TMP_FOLDER_PATH/rpc-address.yaml -f $TMP_FOLDER_PATH/networkName.yaml --set-file config.smartContractInfo=$TMP_FOLDER_PATH/eth-adapter.plugin.json,secrets.orgAccountJson=$TMP_FOLDER_PATH/orgAccount.json
