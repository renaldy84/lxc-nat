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

# Run at container start time if container name starts with 'fw'. The container
# must be started as root for this to work. The container name should be
# passed as the first argument, so it can be used in the firewall log messages.

if [ $# -ne 1 ]; then
    echo "Usage: $0 container_name"
    exit 1
fi

sbin=$(dirname $0)/../nat-sbin

$sbin/nat-fw.sh $1

exec /bin/bash
