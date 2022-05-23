. ../constants.sh
if [ $# == 1 ]; then
  NEW_NETWORK_DIR="$JOIN_NETWORK_DIR-$1"
fi
ethAdapterName=$(cat $ethInfoPath | grep "fullnameOverride" | awk '{print $2}' | tr -d '"')
ethAdapterPort=$(cat $ethServicePath | grep "port" | awk '{print $2}')
ethAdapterUrl=http://$(kubectl get svc $ethAdapterName | grep $ethAdapterName | awk '{print $4}'):$ethAdapterPort
echo "config:" >>  $NEW_NETWORK_DIR/eth-adapter-url.yaml
entry="ethadapterUrl: \"$ethAdapterUrl\""
sed -i "1 a\  ${entry}" $NEW_NETWORK_DIR/eth-adapter-url.yaml
echo $ethAdapterUrl
helm upgrade --install --wait --timeout=600s epi pharmaledger-imi/epi -f $epiInfoPath -f $epiServicePath -f $NEW_NETWORK_DIR/eth-adapter-url.yaml