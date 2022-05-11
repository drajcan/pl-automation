git clone http://github.com/pharmaledger-imi/epi-workspace tmp/epi
cd tmp/epi
npm install
node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"

cd ./ethadapter/EthAdapter
npm install --unsafe-perm --production

cd ../../../../
. values.sh

docker build --no-cache -t $ETH_ADAPTER_REPO_NAME . -f Dockerfile --network host
rm -rf tmp