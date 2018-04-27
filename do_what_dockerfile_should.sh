#!/usr/bin/env bash

INSTALL_DIR="/dendro-install"

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

# install git, curl
apt-get update && apt-get install -y -qq git curl

# boot up virtuoso
/virtuoso.sh &

# wait for virtuoso to boot..
wait_for_server_to_boot_on_port 127.0.0.1 8890
wait_for_server_to_boot_on_port 127.0.0.1 1111

#clone repository
git clone https://github.com/feup-infolab/dendro-install $INSTALL_DIR

# make scripts executable & load ontologies after service boots up... \
/usr/local/virtuoso-opensource/bin/isql-v 1111 -U dba -P dba < $INSTALL_DIR/scripts/SQLCommands/interactive_sql_commands.sql
sync
