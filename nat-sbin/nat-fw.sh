#!/bin/bash

source $(dirname $0)/../functions.sh

echo 1 > /proc/sys/net/ipv4/ip_forward

EXTIF=eth0
INTIF=eth1

EXTNET=$(ifacenet $EXTIF)
INTNET=$(ifacenet $INTIF)

HOST=10.0.3.10

if [ "x$1" = "x" ]; then
    LOG_PREFIX="LXC"
else
    LOG_PREFIX="LXC $1"
fi

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
$IPT -A OUTPUT -p tcp --sport $UNPRIVPORTS -o $EXTIF -j ACCEPT
$IPT -A OUTPUT -p udp --sport $UNPRIVPORTS -o $EXTIF -j ACCEPT
$IPT -A OUTPUT -o $INTIF -j ACCEPT

$IPT -A FORWARD -p icmp -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -p tcp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -p udp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT

$IPT -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE

#$IPT -A INPUT -m limit --limit 10/minute \
#    -i $EXTIF -j LOG --log-prefix "$LOG_PREFIX EXT DROP: "

$IPT -A OUTPUT -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX OUT DROP: "

$IPT -A INPUT -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX IN  DROP: "

$IPT -A FORWARD -m limit --limit 10/minute \
    -j LOG --log-prefix "$LOG_PREFIX FWD DROP: "
