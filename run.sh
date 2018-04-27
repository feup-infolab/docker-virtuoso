#!/usr/bin/env bash

CONTAINER_NAME="virtuoso-dendro"

#list running containers...
docker ps -a

#start container
docker run  -p 8890:8890 \
            -p 1111:1111 \
            --name "$CONTAINER_NAME" \
            -d joaorosilva/virtuoso:7.2.4-for-dendro-0.3

#list running containers...
docker ps -a
