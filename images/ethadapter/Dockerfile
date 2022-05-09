FROM node:16.14.2-alpine

WORKDIR "/ePI-workspace"
ENV SOURCE_FOLDER_NAME="tmp/epi"

COPY $SOURCE_FOLDER_NAME/ethadapter ethadapter
COPY $SOURCE_FOLDER_NAME/privatesky privatesky

WORKDIR /ePI-workspace/ethadapter/EthAdapter

EXPOSE 3000

CMD [ "node" , "index.js" ]