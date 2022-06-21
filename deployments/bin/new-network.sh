if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh

helm show values /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node > $qnValuesPath
if [ ! -f $COMPANY_NAME/tmp/deployment.yaml ]; then
  echo "deployment:" >>  $COMPANY_NAME/tmp/deployment.yaml
  echo "company: \"$COMPANY_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(company\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
  echo "network_name: \"$NETWORK_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(network_name\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
fi

helm pl-plugin --newNetwork -i $qnValuesPath $ghInfoPath $qnInfoPath $newNetworkService $COMPANY_NAME/tmp/deployment.yaml -o $COMPANY_NAME/tmp

helm upgrade --install --wait --timeout=300s qn-0 /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node -f $qnValuesPath -f $newNetworkService -f $qnInfoPath -f $ghInfoPath -f $COMPANY_NAME/tmp/deployment.yaml --set-file use_case.newNetwork.plugin_data_common=$COMPANY_NAME/tmp/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/new-network.plugin.secrets.json

enodeAddress=$(cat $qnInfoPath | grep enode_address: | awk '{print $2}' | tr -d '"')
if [ $enodeAddress == "0.0.0.0" ]; then
  qnPort=$(cat $qnInfoPath | grep enode_address_port: | awk '{print $2}' | tr -d '"')
  enodeAddress=$(kubectl get svc | grep $qnPort | awk '{print $4}')
  enodeAddress="enode_address: \"$enodeAddress\""
  echo $enodeAddress >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(enode_address\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
  helm upgrade --install --wait --timeout=300s qn-0 /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node -f $qnValuesPath -f $ghInfoPath -f $newNetworkService -f $qnInfoPath -f $COMPANY_NAME/tmp/deployment.yaml --set-file use_case.newNetwork.plugin_data_common=$COMPANY_NAME/tmp/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/new-network.plugin.secrets.json
fi

echo "network_name: \"$NETWORK_NAME\"" > $COMPANY_NAME/tmp/networkName.yaml
if [ ! -f $COMPANY_NAME/tmp/rpc-address.yaml ]; then
  rpc_address=http://$(kubectl get svc | grep 8545 | awk '{print $3}'):8545
  echo "config:" >>  $COMPANY_NAME/tmp/rpc-address.yaml
  entry="rpcAddress: \"$rpc_address\""
  echo $entry >> $COMPANY_NAME/tmp/rpc-address.yaml
  sed -i 's/\(rpcAddress\)/\  \1/' $COMPANY_NAME/tmp/rpc-address.yaml
fi
helm pl-plugin --smartContract -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $smartContractInfoPath $COMPANY_NAME/tmp/networkName.yaml -o $COMPANY_NAME/tmp
helm pl-plugin --uploadInfo -i $qnValuesPath $newNetworkService $ghInfoPath $qnInfoPath $COMPANY_NAME/tmp/new-network.plugin.json $COMPANY_NAME/tmp/deployment.yaml $COMPANY_NAME/tmp/networkName.yaml -o $COMPANY_NAME/tmp
