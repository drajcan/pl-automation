FROM debian:latest

RUN apt update && apt install -y curl unzip groff

RUN curl -sL https://deb.nodesource.com/setup_16.x
RUN apt -y install nodejs
RUN apt -y install npm

RUN apt -y install git

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
	./aws/install

RUN aws --version
RUN node --version
RUN npm --version

RUN groupadd -g 1000 -o node
RUN useradd -m -u 1000 -g 1000 -o -s /bin/sh node
ENV TARGET_FOLDER_NAME="backup-restore"
RUN git clone https://github.com/OpenDSU/backup-restore-server.git $TARGET_FOLDER_NAME
RUN chown -R node:node $TARGET_FOLDER_NAME
WORKDIR $TARGET_FOLDER_NAME

USER node

RUN npm install

EXPOSE 3000/tcp

CMD [ "node" , "index.js" ]