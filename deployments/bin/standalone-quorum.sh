if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh

helm upgrade --install --wait --timeout=300s quorum pharmaledger-imi/standalone-quorum

if test -f $COMPANY_NAME/tmp/rpc-address.yaml; then
  rm -f $COMPANY_NAME/tmp/rpc-address.yaml
fi

validatorName=$(kubectl get svc | grep 8545 | awk '{print $1}')
validatorName=($validatorName)
rpc_address=http://$validatorName:8545
echo "config:" >>  $COMPANY_NAME/tmp/rpc-address.yaml
entry="rpcAddress: \"$rpc_address\""
sed -i "1 a\  ${entry}" $COMPANY_NAME/tmp/rpc-address.yaml
podName=$(kubectl get pods | grep validator | awk '{print $1}')
podName=($podName)
echo "pod_name: \"$podName\"" > $COMPANY_NAME/tmp/podName.yaml
echo "network_name: \"$NETWORK_NAME\"" > $COMPANY_NAME/tmp/networkName.yaml
helm pl-plugin --smartContract -i $ghInfoPath $smartContractInfoPath $COMPANY_NAME/tmp/rpc-address.yaml $COMPANY_NAME/tmp/podName.yaml $COMPANY_NAME/tmp/networkName.yaml -o $COMPANY_NAME/tmp
