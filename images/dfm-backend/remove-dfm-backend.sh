. values.sh
docker rm -f $(docker ps -aq -f name=$DFM_BACKEND_NAME)