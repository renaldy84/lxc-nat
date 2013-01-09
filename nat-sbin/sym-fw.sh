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

# Firewall script to force address (and possibly port?) dependent mapping.
# Pre rfc4787, this was discribed as 'symmetric' NAT. To use, run in one
# of the fw* containers.

source $(dirname $0)/../functions.sh

echo 1 > /proc/sys/net/ipv4/ip_forward

EXTIF=eth0
INTIF=eth1

EXTNET=$(ifacenet $EXTIF)
INTNET=$(ifacenet $INTIF)

HOST=10.0.3.10

$IPT -t filter -F
$IPT -t nat -F
$IPT -t mangle -F

$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

$IPT -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

$IPT -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPT -A OUTPUT -m conntrack --ctstate INVALID -j DROP
$IPT -A FORWARD -m conntrack --ctstate INVALID -j DROP

$IPT -A INPUT -s $INTNET -i $INTIF -j ACCEPT
$IPT -A INPUT -s $HOST -i $EXTIF -j ACCEPT
$IPT -A OUTPUT -p icmp -j ACCEPT

$IPT -A FORWARD -p icmp -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -p tcp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -p udp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT

#$IPT -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
$IPT -tnat -A POSTROUTING -o eth0 -p udp -j SNAT \
    --to-source 10.0.3.111-10.0.3.113:50000-51000 --random
$IPT -t nat -A POSTROUTING -o eth0 ! -p udp -j SNAT \
    --to-source 10.0.3.111-10.0.3.113 --random

#$IPT -A INPUT -m limit --limit 10/minute \
#    -i $EXTIF -j LOG --log-prefix "$LOG_PREFIX EXT DROP: "

$IPT -A OUTPUT -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX OUT DROP: "

$IPT -A INPUT -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX IN  DROP: "

$IPT -A FORWARD -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX FWD DROP: "
