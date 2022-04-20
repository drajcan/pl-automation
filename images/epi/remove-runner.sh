. values.sh
docker rm -f $(docker ps -aq -f name=$RUNNER_NAME)