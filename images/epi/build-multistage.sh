#!/bin/bash
. values.sh
export DOCKER_BUILDKIT=1
docker build  --no-cache --target=builder --build-arg NODE_BASE_IMAGE=$NODE_BASE_IMAGE --build-arg NODE_ALPINE_BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE --build-arg GIT_BRANCH=master -t epi:master-builder --rm=false --pull --network host -f=Dockerfile .
docker build --no-cache  --target=runner --build-arg NODE_BASE_IMAGE=$NODE_BASE_IMAGE --build-arg NODE_ALPINE_BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE --build-arg GIT_BRANCH=master -t epi:master-runner --rm=false --pull --network host -f=Dockerfile .

