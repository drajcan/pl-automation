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

ENV TARGET_FOLDER_NAME="backup-restore"
RUN git clone https://github.com/OpenDSU/backup-restore-server.git $TARGET_FOLDER_NAME
WORKDIR $TARGET_FOLDER_NAME

RUN npm install

EXPOSE 3000/tcp

CMD [ "node" , "index.js" ]