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


source $(dirname $0)/../functions.sh

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

EXTIF=eth0
INTIF=eth1

EXTNET=$(ifacenet $EXTIF)
INTNET=$(ifacenet $INTIF)
EXTNET6=$(ifacenet6 $EXTIF)
INTNET6=$(ifacenet6 $INTIF)

HOST=10.0.3.10
HOST6=fd00:0:3::10

if [ "x$1" = "x" ]; then
    LOG_PREFIX="LXC"
else
    LOG_PREFIX="LXC $1"
fi

$IPT -t filter -F
$IPT -t nat -F
$IPT -t mangle -F
$IPT6 -F

ipt46 -P INPUT DROP
ipt46 -P OUTPUT DROP
ipt46 -P FORWARD DROP

ipt46 -A INPUT -i lo -j ACCEPT
ipt46 -A OUTPUT -o lo -j ACCEPT

ipt46 -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ipt46 -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ipt46 -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

ipt46 -A INPUT -m conntrack --ctstate INVALID -j DROP
ipt46 -A OUTPUT -m conntrack --ctstate INVALID -j DROP
ipt46 -A FORWARD -m conntrack --ctstate INVALID -j DROP

$IPT -A INPUT -s $INTNET -i $INTIF -j ACCEPT
$IPT6 -A INPUT -s $INTNET6 -i $INTIF -j ACCEPT
$IPT -A INPUT -s $HOST -i $EXTIF -j ACCEPT
$IPT6 -A INPUT -s $HOST6 -i $EXTIF -j ACCEPT
$IPT -A OUTPUT -p icmp -j ACCEPT
$IPT6 -A OUTPUT -p ipv6-icmp -j ACCEPT
ipt46 -A OUTPUT -p tcp --sport $UNPRIVPORTS -o $EXTIF -j ACCEPT
ipt46 -A OUTPUT -p udp --sport $UNPRIVPORTS -o $EXTIF -j ACCEPT
ipt46 -A OUTPUT -o $INTIF -j ACCEPT

$IPT -A FORWARD -p icmp -i $INTIF -o $EXTIF -j ACCEPT
$IPT6 -A FORWARD -p ipv6-icmp -i $INTIF -o $EXTIF -j ACCEPT
ipt46 -A FORWARD -p tcp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT
ipt46 -A FORWARD -p udp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT

ipt46 -A OUTPUT -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX OUT DROP: "

ipt46 -A INPUT -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX IN  DROP: "

ipt46 -A FORWARD -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX FWD DROP: "

# NAT is ipv4 only
$IPT -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
