FROM debian:latest

RUN apt-get update && \
	apt-get -y install nodejs && \
	apt-get -y install npm --no-install-recommends

RUN npm install -g node-gyp

RUN apt-get -y install git

ENV TARGET_FOLDER_NAME="ePI-workspace"
RUN git clone https://github.com/PharmaLedger-IMI/epi-workspace.git $TARGET_FOLDER_NAME

RUN cd $TARGET_FOLDER_NAME && \
    npm run dev-install --unsafe-perm

RUN cd $TARGET_FOLDER_NAME && \
    node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"

#remove unnecessary files after the installation
RUN find . -name package-lock.json -exec rm {} \;

RUN cd $TARGET_FOLDER_NAME && find . -type d \( -path ./node_modules -o -path ./leaflet-ssapp -o -path  \) -prune -o -name 'node_modules' -exec rm -rf {} \; || true

RUN cd $TARGET_FOLDER_NAME && \
    echo 'npm run server & \n sleep 1m \n node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js ssapps-and-wallets-build"' >> execute-build.sh
RUN cd $TARGET_FOLDER_NAME && cat execute-build.sh

CMD cd $TARGET_FOLDER_NAME && \
    bash execute-build.sh