if [ $# == 0 ]; then
  echo "Expected 1 argument: the company name"
  exit
fi
COMPANY_NAME=$1
. $COMPANY_NAME/tmp/config-context.sh

ethAdapterName=$(cat $ethInfoPath | grep "fullnameOverride" | awk '{print $2}' | tr -d '"')
ethAdapterPort=$(cat $ethServicePath | grep "port" | awk '{print $2}')
ethAdapterUrl=http://$(kubectl get svc $ethAdapterName | grep $ethAdapterName | awk '{print $4}'):$ethAdapterPort
if test -f $COMPANY_NAME/tmp/eth-adapter-url.yaml; then
  rm -f $COMPANY_NAME/tmp/eth-adapter-url.yaml
fi
echo "config:" >>  $COMPANY_NAME/tmp/eth-adapter-url.yaml
entry="ethadapterUrl: \"$ethAdapterUrl\""
sed -i "1 a\  ${entry}" $COMPANY_NAME/tmp/eth-adapter-url.yaml
echo $ethAdapterUrl
helm upgrade --install --wait --timeout=600s epi pharmaledger-imi/epi -f $epiInfoPath -f $epiServicePath -f $COMPANY_NAME/tmp/eth-adapter-url.yaml
rm -rf $COMPANY_NAME/tmp