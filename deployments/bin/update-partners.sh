if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh

helm show values /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node > $qnValuesPath

if [ ! -f $COMPANY_NAME/tmp/deployment.yaml ]; then
  echo "deployment.yaml does not exist. Creating it now"
  echo "deployment:" >>  $COMPANY_NAME/tmp/deployment.yaml
  echo "company: \"$COMPANY_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(company\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
  echo "network_name: \"$NETWORK_NAME\"" >>  $COMPANY_NAME/tmp/deployment.yaml
  sed -i 's/\(network_name\)/\  \1/' $COMPANY_NAME/tmp/deployment.yaml
else
  echo "deployment.yaml already exists"
fi

echo "network_name: \"$NETWORK_NAME\"" > $COMPANY_NAME/tmp/networkName.yaml

helm pl-plugin --updatePartnersInfo -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $updatePartnersInfo $COMPANY_NAME/tmp/deployment.yaml $COMPANY_NAME/tmp/networkName.yaml -o $COMPANY_NAME/tmp

if test -f $COMPANY_NAME/tmp/join; then
  echo "Join network ---------------------"
  helm pl-plugin --updatePartnersInfo -i $qnValuesPath $joinNetworkInfo $ghInfoPath $qnInfoPath $COMPANY_NAME/tmp/deployment.yaml $COMPANY_NAME/tmp/networkName.yaml $updatePartnersInfo -o $COMPANY_NAME/tmp
  helm upgrade --install qn-0 /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $joinNetworkInfo -f $COMPANY_NAME/tmp/deployment.yaml -f $COMPANY_NAME/tmp/networkName.yaml -f $updatePartnersInfo --set-file use_case.joinNetwork.plugin_data_common=$COMPANY_NAME/tmp/join-network.plugin.json,use_case.joinNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/join-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=$COMPANY_NAME/tmp/update-partners-info.plugin.json
  rm -f join
#  rm -rf $COMPANY_NAME/tmp
else
  echo "new network ------------------"
  helm pl-plugin --updatePartnersInfo -i $qnValuesPath $ghInfoPath $newNetworkService $qnInfoPath $updatePartnersInfo $COMPANY_NAME/tmp/deployment.yaml $COMPANY_NAME/tmp/networkName.yaml -o $COMPANY_NAME/tmp
  helm upgrade --install qn-0 /home/skutner/WebstormProjects/work/helm-charts/charts/quorum-node -f $qnValuesPath -f $ghInfoPath -f $qnInfoPath -f $newNetworkService -f $COMPANY_NAME/tmp/deployment.yaml -f $COMPANY_NAME/tmp/networkName.yaml -f $updatePartnersInfo --set-file use_case.newNetwork.plugin_data_common=$COMPANY_NAME/tmp/new-network.plugin.json,use_case.newNetwork.plugin_data_secrets=$COMPANY_NAME/tmp/new-network.plugin.secrets.json,use_case.updatePartnersInfo.plugin_data_common=$COMPANY_NAME/tmp/update-partners-info.plugin.json
#  rm -rf $COMPANY_NAME/tmp
fi