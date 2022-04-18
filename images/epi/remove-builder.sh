. values.sh
docker rm -f $(docker ps -q -f name=$BUILDER_NAME)