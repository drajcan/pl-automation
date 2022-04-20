. values.sh
docker run --detach --hostname epi --publish 8080:8080 --read-only --name $RUNNER_NAME --volume=volume:/ePI-workspace/apihub-root/external-volume ${HUB_IDENTIFIER}/$RUNNER_REPO_NAME