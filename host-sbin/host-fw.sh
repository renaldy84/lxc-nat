#!/bin/bash

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

for iface in brpub brint1 brint2; do
    $IPT -A lxc-forward -i $iface -o $iface -j ACCEPT
    $IPT -A lxc-input -i $iface -j ACCEPT
    $IPT -A lxc-output -o $iface -j ACCEPT
done
