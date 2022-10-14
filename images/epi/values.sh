#!/bin/bash
echo "Setting variables ..."
NODE_ALPINE_BASE_IMAGE='node:16.17.0-alpine'
NODE_BASE_IMAGE='node:16.17.0'
HUB_IDENTIFIER='docker.io'
BUILDER_NAME='epi-builder'
BUILDER_REPO_NAME='pharmaledger/epi-builder'
if [[ -z "$VERSION" ]]; then
  VERSION='1.5.4'
fi
RUNNER_NAME='epi-runner'
BUILD_TYPE='dev'
RUNNER_REPO_NAME='pharmaledger/epi-runner'
