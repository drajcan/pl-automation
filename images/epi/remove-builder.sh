. values.sh
docker rm -f $(docker ps -aq -f name=$BUILDER_NAME)