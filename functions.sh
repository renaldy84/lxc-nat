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


PRIVPORTS="0:1023"                   # well-known, privileged port range
UNPRIVPORTS="1024:65535"             # unprivileged port range

IPT=/sbin/iptables
IPT6=/sbin/ip6tables

ipt46() {
    $IPT "$@"
    $IPT6 "$@"
}

mkchain() {
    table=$1
    if [ "$table" = "6" ]; then
        cmd="$IPT6"
    else
        cmd="$IPT -t $table"
    fi
    chain=$2
    $cmd -L $chain >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        $cmd -N $chain
    else
        $cmd -F $chain
    fi
}

insertrule() {
    table=$1
    chain=$2
    shift; shift
    if [ "$table" = "6" ]; then
        cmd="$IPT6"
    else
        cmd="$IPT -t $table"
    fi
    $cmd -C $chain "$@"
    if [ $? -ne 0 ]; then
        $cmd -I $chain "$@"
    fi
}

ifacenet() {
    iface=$1
    echo $(ip addr show dev $1 | grep '^\s*inet ' | awk '{ print $2 }')
}

ifacenet6() {
    iface=$1
    echo $(ip addr show dev $1 | grep '^\s*inet6 .*scope global' | awk '{ print $2 }')
}
