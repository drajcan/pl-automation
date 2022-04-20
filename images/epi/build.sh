git clone http://github.com/pharmaledger-imi/epi-workspace tmp/epi
cd tmp/epi
npm run dev-install
node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"
cd ../../

. values.sh

DOCKER_BUILDKIT=1 docker build --no-cache -t $BUILDER_REPO_NAME . -f builder-dockerfile --network host
DOCKER_BUILDKIT=1 docker build --no-cache -t $RUNNER_REPO_NAME . -f runner-dockerfile --network host

rm -rf tmp/epi