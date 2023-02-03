if [ $# -le 1 ]; then
  echo "Expected 2 argument: company_name and network_name"
  exit
fi
COMPANY_NAME=$1
NETWORK_NAME=$2
. $COMPANY_NAME/$NETWORK_NAME/config-context.sh

helm upgrade --install --wait --timeout=600s quorum pharmaledger-imi/standalone-quorum

if test -f $TMP_FOLDER_PATH/rpc-address.yaml; then
  rm -f $TMP_FOLDER_PATH/rpc-address.yaml
fi

if [ ! -f $TMP_FOLDER_PATH/rpc-address.yaml ]; then
  validatorName=$(kubectl get svc | grep 8545 | awk '{print $1}')
  validatorName=($validatorName)
  rpc_address=http://$validatorName:8545
  echo "config:" >>  $TMP_FOLDER_PATH/rpc-address.yaml
  entry="rpcAddress: \"$rpc_address\""
  sed -i "1 a\  ${entry}" $TMP_FOLDER_PATH/rpc-address.yaml
fi

podName=$(kubectl get pods | grep validator | awk '{print $1}')
podName=($podName)
echo "pod_name: \"$podName\"" > $TMP_FOLDER_PATH/podName.yaml
echo "network_name: \"$NETWORK_NAME\"" > $TMP_FOLDER_PATH/networkName.yaml
helm pl-plugin --smartContract -i $ghInfoPath $smartContractInfoPath $TMP_FOLDER_PATH/rpc-address.yaml $TMP_FOLDER_PATH/podName.yaml $TMP_FOLDER_PATH/networkName.yaml -o $TMP_FOLDER_PATH
