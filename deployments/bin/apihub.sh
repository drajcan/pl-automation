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

ethAdapterName=$(cat $ethInfoPath | grep "fullnameOverride" | awk '{print $2}' | tr -d '"')
ethAdapterPort=$(cat $ethServicePath | grep "port" | awk '{print $2}')
ethAdapterUrl=http://$(kubectl get svc $ethAdapterName | grep $ethAdapterName | awk '{print $3}'):$ethAdapterPort
if test -f $TMP_FOLDER_PATH/eth-adapter-url.yaml; then
  rm -f $TMP_FOLDER_PATH/eth-adapter-url.yaml
fi
echo "config:" >>  $TMP_FOLDER_PATH/eth-adapter-url.yaml
entry="ethadapterUrl: \"$ethAdapterUrl\""
sed -i "1 a\  ${entry}" $TMP_FOLDER_PATH/eth-adapter-url.yaml
helm upgrade --install --debug --wait --timeout=600s epi pharmaledger-imi/epi -f $epiInfoPath -f $epiServicePath -f $TMP_FOLDER_PATH/eth-adapter-url.yaml