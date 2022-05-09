#!/bin/bash

docker build --no-cache --target=builder --build-arg GIT_BRANCH=master -t ethadapter:master-builder --rm=false --pull --network host -f=dockerfile .
