#!/bin/bash

MM_VERSION="v$(lastversion https://github.com/SmartHoneybee/ubiquitous-memory/)"

docker login -u="${RD_OPTION_DOCKER_USERNAME}" -p="${RD_OPTION_DOCKER_PASSWORD}"
docker build --build-arg MM_VERSION="${MM_VERSION}" -t ${RD_OPTION_DOCKER_USERNAME}/mattermost:latest -t ${RD_OPTION_DOCKER_USERNAME}/mattermost:${MM_VERSION} .
docker push ${RD_OPTION_DOCKER_USERNAME}/mattermost:latest
docker push ${RD_OPTION_DOCKER_USERNAME}/mattermost:${MM_VERSION}