if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $TMP_FOLDER_PATH/config-context.sh

ethAdapterName=$(cat $ethInfoPath | grep "fullnameOverride" | awk '{print $2}' | tr -d '"')
ethAdapterPort=$(cat $ethServicePath | grep "port" | awk '{print $2}')
ethAdapterUrl=http://$(kubectl get svc $ethAdapterName | grep $ethAdapterName | awk '{print $3}'):$ethAdapterPort
if test -f $TMP_FOLDER_PATH/eth-adapter-url.yaml; then
  rm -f $TMP_FOLDER_PATH/eth-adapter-url.yaml
fi
echo "config:" >>  $TMP_FOLDER_PATH/eth-adapter-url.yaml
entry="ethadapterUrl: \"$ethAdapterUrl\""
sed -i "1 a\  ${entry}" $TMP_FOLDER_PATH/eth-adapter-url.yaml
helm upgrade --install --wait --timeout=600s epi pharmaledger-imi/epi -f $epiInfoPath -f $epiServicePath -f $TMP_FOLDER_PATH/eth-adapter-url.yaml