if [ $# != 2 ]; then
  echo "Expected 2 arguments: company name and network name"
  exit
fi

COMPANY_NAME=$1
NETWORK_NAME=$2

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

if [[ ! -d $COMPANY_NAME ]]; then
  mkdir $COMPANY_NAME
  mkdir $COMPANY_NAME/$NETWORK_NAME
fi
rm -rf $COMPANY_NAME/$NETWORK_NAME/tmp
cp -rn  $SCRIPT_DIR/../company-private-configs/network-name/* $COMPANY_NAME/$NETWORK_NAME
cp $SCRIPT_DIR/../company-private-configs/network-name/private/github.info.yaml $COMPANY_NAME/$NETWORK_NAME/private
CONST_PATH=../config-context.sh
SET_CONTEXT_PATH=$(realpath $SCRIPT_DIR/$CONST_PATH)
TMP_FOLDER_PATH=$COMPANY_NAME/$NETWORK_NAME/tmp
echo $TMP_FOLDER_PATH
mkdir -p $COMPANY_NAME/$NETWORK_NAME/tmp
touch $COMPANY_NAME/$NETWORK_NAME/tmp/.temp
echo $SET_CONTEXT_PATH
cp $SET_CONTEXT_PATH $COMPANY_NAME/$NETWORK_NAME
CONFIG_CONTEXT_PATH=$COMPANY_NAME/$NETWORK_NAME/config-context.sh
sed -i "1s|^|COMPANY_NAME=$COMPANY_NAME\n|" $CONFIG_CONTEXT_PATH
sed -i "2s|^|NETWORK_NAME=$NETWORK_NAME\n|" $CONFIG_CONTEXT_PATH
sed -i "3s|^|TMP_FOLDER_PATH=$TMP_FOLDER_PATH\n|" $CONFIG_CONTEXT_PATH

