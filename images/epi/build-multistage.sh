#!/bin/bash

export DOCKER_BUILDKIT=1
docker build --target=builder --build-arg GIT_BRANCH=master -t epi:master-builder --rm=false --pull --network host -f=Dockerfile .
docker build --target=runner --build-arg GIT_BRANCH=master -t epi:master-runner --rm=false --pull --network host -f=Dockerfile .

