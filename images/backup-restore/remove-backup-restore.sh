. values.sh
docker rm -f $(docker ps -aq -f name=$BACKUP_RESTORE_NAME)