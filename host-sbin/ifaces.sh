#!/bin/bash

# Create brpub, brint1/2, and brdub1/2
# Must be run as root before starting any containers.

brctl addbr brpub
for n in $(seq 10 13); do
    ip addr add 10.0.3.$n/24 dev brpub
done
ip link set brpub up

for i in $(seq 2); do
    iface=brint$i
    brctl addbr $iface
    brctl setfd $iface 0
    ip addr add 10.0.$i.10/24 dev $iface
    ip link set $iface up

    iface=brdub$i
    brctl addbr $iface
    brctl setfd $iface 0
    ip addr add 10.0.1$i.10/24 dev $iface
    ip link set $iface up
done
