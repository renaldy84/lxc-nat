#!/bin/bash

brctl addbr brpub
ip addr add 10.0.3.10/24 dev brpub
ip link set brpub up

for i in $(seq 2); do
    iface=brint$i
    brctl addbr $iface
    brctl setfd $iface 0
    ip addr add 10.0.$i.10/24 dev $iface
    ip link set $iface up
done
