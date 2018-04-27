#!/usr/bin/env bash

CONTAINER_NAME="virtuoso-dendro"

docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

docker build -t virtuoso:7.2.4-for-dendro-0.3 .
docker tag virtuoso:7.2.4-for-dendro-0.3 joaorosilva/virtuoso:7.2.4-for-dendro-0.3

# update images

./run.sh

# ./push.sh
