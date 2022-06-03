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
  cp -r $SCRIPT_DIR/../company-private-configs/network-name/* $COMPANY_NAME/$NETWORK_NAME
fi

CONST_PATH=../config-context.sh
SET_CONTEXT_PATH=$(realpath $SCRIPT_DIR/$CONST_PATH)
mkdir $COMPANY_NAME/tmp
cp $SET_CONTEXT_PATH $COMPANY_NAME/tmp
sed -i "1s/^/COMPANY_NAME=$COMPANY_NAME\n/" $COMPANY_NAME/tmp/config-context.sh
sed -i "2s/^/NETWORK_NAME=$NETWORK_NAME\n/" $COMPANY_NAME/tmp/config-context.sh

