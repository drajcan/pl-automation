. values.sh
docker rm -f $(docker ps -q -f name=$RUNNER_NAME)