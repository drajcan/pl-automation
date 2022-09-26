#!/bin/bash
. values.sh
docker build --no-cache --target=builder --build-arg NODE_BASE_IMAGE=$NODE_BASE_IMAGE --build-arg NODE_ALPINE_BASE_IMAGE=$NODE_ALPINE_BASE_IMAGE --build-arg GIT_BRANCH=master -t ethadapter:master-builder --rm=false --pull --network host -f=dockerfile .
