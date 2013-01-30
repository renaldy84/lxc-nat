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

# Create brpub, brint1/2, and brdub1/2
# Must be run as root before starting any containers.

brctl addbr brpub
for n in $(seq 10 13); do
    ip addr add 10.0.3.$n/24 dev brpub
    ip addr add fd00:0:3::$n/48 dev brpub
done
ip link set brpub up

for i in $(seq 2); do
    iface=brint$i
    brctl addbr $iface
    brctl setfd $iface 0
    ip addr add 10.0.$i.10/24 dev $iface
    ip addr add fd00:0:$i::10/48 dev $iface
    ip link set $iface up

    iface=brdub$i
    brctl addbr $iface
    brctl setfd $iface 0
    ip addr add 10.0.1$i.10/24 dev $iface
    ip addr add fd00:0:1$i::10/48 dev $iface
    ip link set $iface up
done

ip -6 route add fd00:0:1::/48 via fd00:0:3::101
ip -6 route add fd00:0:2::/48 via fd00:0:3::102
