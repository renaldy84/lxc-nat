#!/bin/bash

# Allow traffic in/out from all bridge interfaces, and allow all traffic
# inside the bridge. Creates new chains and inserts them at the top of
# the main filter chains, to create clean separation from any existing
# host firewall.

source $(dirname $0)/../functions.sh

#mkchain nat lxc-postrouting
#insertrule nat POSTROUTING -j lxc-postrouting

mkchain filter lxc-forward
insertrule filter FORWARD -j lxc-forward

mkchain filter lxc-input
insertrule filter INPUT -j lxc-input

mkchain filter lxc-output
insertrule filter OUTPUT -j lxc-input


EXTNET=10.10.3.0/24

for iface in brpub brint1 brint2 brdub1 brdub2; do
    $IPT -A lxc-forward -i $iface -o $iface -j ACCEPT
    $IPT -A lxc-input -i $iface -j ACCEPT
    $IPT -A lxc-output -o $iface -j ACCEPT
done
