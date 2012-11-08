#!/bin/bash

for i in $(seq 2); do
    name=client$i
    conf_file=/tmp/lxc-$name.conf
    cat > $conf_file <<END
lxc.utsname = $name
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brint$i
#lxc.network.hwaddr = 4a:49:43:49:79:f$i
lxc.network.ipv4 = 10.0.$i.2/24
lxc.network.ipv4.gateway = 10.0.$i.1
END
    lxc-create -n $name -f $conf_file

    name=fw$i
    conf_file=/tmp/lxc-$name.conf
    cat > $conf_file <<END
lxc.utsname = $name

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brpub
lxc.network.ipv4 = 10.0.3.10$i/24

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brint$i
lxc.network.ipv4 = 10.0.$i.1/24
END
    lxc-create -n $name -f $conf_file

done


for i in $(seq 3); do
    name=server$i
    conf_file=/tmp/lxc-$name.conf
    cat > $conf_file <<END
lxc.utsname = $name

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brpub
lxc.network.ipv4 = 10.0.3.11$i/24
END
    lxc-create -n $name -f $conf_file

done
