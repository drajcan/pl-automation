. values.sh

DOCKER_BUILDKIT=1 docker build -t $BUILDER_REPO_NAME builder --network host
DOCKER_BUILDKIT=1 docker build -t $RUNNER_REPO_NAME runner --network host
