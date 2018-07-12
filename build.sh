#!/usr/bin/env bash

# Constants and auxiliary functions
# starts containers with the volumes mounted

function wait_for_server_to_boot_on_port()
{
    local ip=$1
    local sentenceToFindInResponse=$2

    if [[ $ip == "" ]]; then
      ip="127.0.0.1"
    fi
    local port=$2
    local attempts=0
    local max_attempts=60

    echo "Waiting for server on $ip:$port to boot up..."

    response=$(curl -s $ip:$port)
    echo $response

	until $(curl --output /dev/null --silent --head --fail http://$ip:$port) || [[ $attempts > $max_attempts ]]; do
        attempts=$((attempts+1))
        echo "waiting... (${attempts}/${max_attempts})"
        sleep 1;
	done

    if (( $attempts == $max_attempts ));
    then
        echo "Server on $ip:$port failed to start after $max_attempts"
    elif (( $attempts < $max_attempts ));
    then
        echo "Server on $ip:$port started successfully at attempt (${attempts}/${max_attempts})"
    fi
}

# Constants

CONTAINER_NAME="virtuoso-dendro"
CONTAINER_TAG="7.2.4-for-dendro-0.4"
LOCAL_TAG="virtuoso:$CONTAINER_TAG"
COMMITTED_IMAGE_TAG="virtuoso-loaded-with-ontologies"
REPOSITORY_TAG="joaorosilva/virtuoso:$CONTAINER_TAG"

# Destroy container...

docker stop "$CONTAINER_NAME"
docker rm -f "$CONTAINER_NAME"
docker rmi -f "$CONTAINER_NAME"


# Build Container...

docker build -t "$LOCAL_TAG" .

docker run --name "$CONTAINER_NAME" \
                  "$LOCAL_TAG" &

wait_for_server_to_boot_on_port "127.0.0.1" "8890"
wait_for_server_to_boot_on_port "127.0.0.1" "1111"

docker ps -a

docker exec -i -t "$CONTAINER_NAME" \
  /bin/bash -c "/usr/local/virtuoso-opensource/bin/isql-v 1111 -U dba -P dba < /dendro-install/scripts/SQLCommands/declare_namespaces.sql"

docker commit "$CONTAINER_NAME" "$COMMITTED_IMAGE_TAG"

docker tag "$COMMITTED_IMAGE_TAG" "$REPOSITORY_TAG"

# update images

docker push "$REPOSITORY_TAG"

# ./push.sh
