#!/bin/bash

# Start bash within a network only container of the given name. The container
# must already have been created, see host-sbin/create-containers.sh. The
# container is run within a screen session of the same name, so it can be
# detatched with C-a C-d if needed and reattached with
# screen -r container_name.

if [ $# -ne 1 ]; then
    echo "Usage: $0 container_name"
    exit 1
fi

NAME=$1

if [[ $NAME = fw* ]]; then
    init=$(dirname $0)/../init/fw.sh
else
    init=/bin/bash
fi
screen -S $NAME -- sudo lxc-start -n $NAME $init
