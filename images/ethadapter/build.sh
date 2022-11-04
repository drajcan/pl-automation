git clone http://github.com/pharmaledger-imi/epi-workspace tmp/epi
cd tmp/epi
rm -rf ethadapter
git clone http://github.com/skutner/eth-adapter ethadapter
npm install
node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"

cd ./ethadapter/EthAdapter
npm install --unsafe-perm --production

cd ../../../../
. values.sh

docker build --no-cache -t $ETH_ADAPTER_REPO_NAME --build-arg NODE_ALPINE_BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE --build-arg NODE_BASE_IMAGE=$NODE_BASE_IMAGE . -f Dockerfile --network host
#rm -rf tmp