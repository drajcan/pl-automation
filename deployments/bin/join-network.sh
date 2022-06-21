if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh
touch $COMPANY_NAME/tmp/join
helm show values /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node > $qnValuesPath
if [ ! -f $COMPANY_NAME/tmp/deployment.yaml ]; then
  echo "deployment:" >>  $COMPANY_NAME/tmp/deployment.yaml
  echo "company: \"$COMPANY_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(company\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
  echo "network_name: \"$NETWORK_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(network_name\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
fi

helm pl-plugin --joinNetwork -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $COMPANY_NAME/tmp/deployment.yaml -o $COMPANY_NAME/tmp

helm upgrade --install qn-0 /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $COMPANY_NAME/tmp/deployment.yaml --set-file use_case.joinNetwork.plugin_data_common=$COMPANY_NAME/tmp/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/join-network.plugin.secrets.json && sleep 30
enodeAddress=$(cat $qnInfoPath | grep enode_address: | awk '{print $2}' | tr -d '"')
if [ $enodeAddress == "0.0.0.0" ]; then
  echo $qnInfoPath
  cat $qnInfoPath
  qnPort=$(cat $qnInfoPath | grep enode_address_port: | awk '{print $2}' | tr -d '"')
  echo $qnPort
  enodeAddress=$(kubectl get svc | grep $qnPort | awk '{print $4}')
  enodeAddress="enode_address: \"$enodeAddress\""
  echo $enodeAddress >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(enode_address\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
  helm upgrade --install qn-0 /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $COMPANY_NAME/tmp/deployment.yaml --set-file use_case.joinNetwork.plugin_data_common=$COMPANY_NAME/tmp/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/join-network.plugin.secrets.json
fi

echo "network_name: \"$NETWORK_NAME\"" > $COMPANY_NAME/tmp/networkName.yaml
helm pl-plugin --uploadInfo -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $COMPANY_NAME/tmp/join-network.plugin.json $COMPANY_NAME/tmp/deployment.yaml $COMPANY_NAME/tmp/networkName.yaml -o $COMPANY_NAME/tmp
