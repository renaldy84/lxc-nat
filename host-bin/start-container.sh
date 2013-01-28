#!/bin/bash
# Copyright 2013 University of Chicago
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    init="$(dirname $0)/../init/fw.sh $NAME"
    sudo=sudo
else
    init=/bin/bash
    sudo=""
fi
screen -S $NAME -- $sudo lxc-start -n $NAME $init
