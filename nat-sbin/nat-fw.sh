#!/bin/bash

source $(dirname $0)/../functions.sh

EXTIF=eth0
INTIF=eth1

EXTNET=$(ifacenet $EXTIF)
INTNET=$(ifacenet $INTIF)

$IPT -t filter -F
$IPT -t nat -F
$IPT -t mangle -F

$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

$IPT -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

$IPT -A INPUT -m state --state INVALID -j DROP 
$IPT -A OUTPUT -m state --state INVALID -j DROP 
$IPT -A FORWARD -m state --state INVALID -j DROP

$IPT -A INPUT -s $INTNET -i $INTIF -j ACCEPT
$IPT -A INPUT -s $EXTNET -i $EXTIF -j ACCEPT
$IPT -A OUTPUT -p icmp -j ACCEPT

$IPT -A FORWARD -p icmp -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -p tcp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT
$IPT -A FORWARD -p udp --sport $UNPRIVPORTS -i $INTIF -o $EXTIF -j ACCEPT

$IPT -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE

$IPT -A OUTPUT -m limit --limit 10/hour \
    -o $INTIF -j LOG --log-prefix "OUT DROP: "

$IPT -A INPUT -m limit --limit 10/hour \
    -i $INTIF -j LOG --log-prefix "IN  DROP: "

$IPT -A FORWARD -m limit --limit 10/hour \
    -i $INTIF -j LOG --log-prefix "FWD DROP: "
