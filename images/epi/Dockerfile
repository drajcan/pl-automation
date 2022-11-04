#
# "Base" Docker image containing the cloned software with initial build steps.
# This (base) image is never being used at runtime and will not be deployed anywhere.
# It is an important part of the multi-stage docker build for "builder" and the "runner" image.
#
ARG NODE_ALPINE_BASE_IMAGE=node:16.17.0-alpine
ARG NODE_BASE_IMAGE=node:16.17.0
FROM $NODE_BASE_IMAGE as base

# GIT_BRANCH=Branch/Tag/Commit Hash to clone from https://github.com/PharmaLedger-IMI/epi-workspace - Defaults to master
ARG GIT_BRANCH
ENV GIT_BRANCH=${GIT_BRANCH:-master}
ARG SOURCE="/tmp/epi"

RUN git clone -b ${GIT_BRANCH} --single-branch --depth 1 https://github.com/PharmaLedger-IMI/epi-workspace.git ${SOURCE} && \
    cd ${SOURCE} && \
    npm run dev-install && \
    node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js postinstall"

# Remove all Git and GitHub related files and directories - see https://gist.github.com/facelordgists/80e868ff5e315878ecd6
RUN find . \( -name ".git" -o -name ".gitignore" -o -name ".gitmodules" -o -name ".gitattributes" -o -name ".github" \) -exec rm -rf -- {} +

# -----------------------------------------------------------------------------------
#
# "Builder" image for creating the Apps at initial and installation ans subsequent upgrades.
# It does not expose any ports and does not serve any http traffic to users!
#
# Sample for building:
# docker build --target=builder --build-arg GIT_BRANCH=master -t epi:master-builder --rm=false --pull --network host -f=Dockerfile .
#
FROM $NODE_ALPINE_BASE_IMAGE as builder

WORKDIR "/ePI-workspace"
ARG SOURCE="/tmp/epi"

COPY --from=base ${SOURCE}/apihub-root apihub-root
COPY --from=base ${SOURCE}/bin bin
COPY --from=base ${SOURCE}/cardinal cardinal
COPY --from=base ${SOURCE}/demiurge demiurge
COPY --from=base ${SOURCE}/dsu-fabric-ssapp dsu-fabric-ssapp
COPY --from=base ${SOURCE}/gtin-dsu-wizard gtin-dsu-wizard
COPY --from=base ${SOURCE}/gtin-resolver gtin-resolver
COPY --from=base ${SOURCE}/leaflet-ssapp leaflet-ssapp
COPY --from=base ${SOURCE}/opendsu-sdk opendsu-sdk
COPY --from=base ${SOURCE}/reporting-service reporting-service
COPY --from=base ${SOURCE}/themes themes
COPY --from=base ${SOURCE}/webcardinal webcardinal
COPY --from=base ${SOURCE}/node_modules node_modules
COPY aliasSSIPatches ./
COPY --from=base ${SOURCE}/env.json.devel ${SOURCE}/octopus.json ${SOURCE}/octopus-freeze.json ${SOURCE}/package.json ${SOURCE}/env.json ${SOURCE}/.npmrc ${SOURCE}/README.md ./

RUN printf 'npm run server & \n sleep 1m \n node ./node_modules/octopus/scripts/setEnv --file=../../../env.json "node ./bin/octopusRun.js epi-ssapps-and-wallets-build"' >> execute-build.sh
RUN cat execute-build.sh

CMD /bin/sh execute-build.sh


# -----------------------------------------------------------------------------------
#
# "Runner" image for being used at runtime for serving traffic to users.
#
# Sample for building:
# docker build --target=runner --build-arg GIT_BRANCH=master -t epi:master-runner --rm=false --pull --network host -f=Dockerfile .
#
FROM $NODE_ALPINE_BASE_IMAGE as runner

WORKDIR "/ePI-workspace"
ARG SOURCE="/tmp/epi"

COPY --from=base ${SOURCE}/apihub-root apihub-root
COPY --from=base ${SOURCE}/opendsu-sdk opendsu-sdk
COPY --from=base ${SOURCE}/gtin-resolver gtin-resolver
COPY --from=base ${SOURCE}/gtin-dsu-wizard gtin-dsu-wizard
COPY --from=base ${SOURCE}/reporting-service reporting-service
COPY --from=base ${SOURCE}/node_modules node_modules
COPY --from=base ${SOURCE}/env.json.devel ${SOURCE}/octopus.json ${SOURCE}/octopus-freeze.json ${SOURCE}/package.json ${SOURCE}/env.json ${SOURCE}/.npmrc ${SOURCE}/README.md ./

RUN printf 'npm run server & \n tail -f /dev/null' >> run.sh
RUN cat run.sh

EXPOSE 8080/tcp

CMD /bin/sh run.sh