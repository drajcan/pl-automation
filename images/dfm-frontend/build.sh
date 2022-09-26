. values.sh
docker build --no-cache -t $DFM_FRONTEND_REPO_NAME --build-arg NODE_BUSTER_BASE_IMAGE=$NODE_BUSTER_BASE_IMAGE . -f Dockerfile --network host