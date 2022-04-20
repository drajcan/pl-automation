. values.sh
docker run --detach --hostname epi  --read-only --name $BUILDER_NAME --volume=volume:/ePI-workspace/apihub-root/external-volume ${HUB_IDENTIFIER}/$BUILDER_REPO_NAME