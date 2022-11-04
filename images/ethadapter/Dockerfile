ARG NODE_ALPINE_BASE_IMAGE=node:16.17.0-alpine
FROM $NODE_ALPINE_BASE_IMAGE

WORKDIR "/ePI-workspace"
ENV SOURCE_FOLDER_NAME="tmp/epi"

COPY $SOURCE_FOLDER_NAME/ethadapter ethadapter
COPY $SOURCE_FOLDER_NAME/opendsu-sdk opendsu-sdk

WORKDIR /ePI-workspace/ethadapter/EthAdapter

EXPOSE 3000

CMD [ "node" , "index.js" ]