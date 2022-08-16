. values.sh
docker rm -f $(docker ps -aq -f name=$MAINTENANCE_NAME)