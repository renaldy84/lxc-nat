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
lxc.network.ipv6 = fd00:0:$i::2
lxc.network.ipv6.gateway = fd00:0:$i::1
END
    lxc-destroy -n $name
    lxc-create -n $name -f $conf_file

    name=fw$i
    conf_file=/tmp/lxc-$name.conf
    cat > $conf_file <<END
lxc.utsname = $name

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brpub
lxc.network.ipv4 = 10.0.3.10$i/24
lxc.network.ipv6 = fd00:0:3::10$i

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brint$i
lxc.network.ipv4 = 10.0.$i.1/24
lxc.network.ipv6 = fd00:0:$i::1
END
    lxc-destroy -n $name
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
lxc.network.ipv6 = fd00:0:3::11$i
END
    lxc-destroy -n $name
    lxc-create -n $name -f $conf_file

done


# Containers for double-NAT testing. fwdubN are behind fwN, attached
# to brintN, with another private network attacked brdupN with clients
# dubclientN.
for i in $(seq 2); do
    name=dubclient$i
    conf_file=/tmp/lxc-$name.conf
    cat > $conf_file <<END
lxc.utsname = $name
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brdub$i
lxc.network.ipv4 = 10.0.1$i.2/24
lxc.network.ipv4.gateway = 10.0.1$i.1
lxc.network.ipv6 = fd00:0:1$i::2
lxc.network.ipv6.gateway = fd00:0:1$i::1
END
    lxc-destroy -n $name
    lxc-create -n $name -f $conf_file


    name=fwdub$i
    conf_file=/tmp/lxc-$name.conf
    cat > $conf_file <<END
lxc.utsname = $name

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brint$i
lxc.network.ipv4 = 10.0.$i.20$i/24
lxc.network.ipv4.gateway = 10.0.$i.1
lxc.network.ipv6 = fd00:0:$i::20$i
lxc.network.ipv6.gateway = fd00:0:$i::1

lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = brdub$i
lxc.network.ipv4 = 10.0.1$i.1/24
lxc.network.ipv6 = fd00:0:1$i::1
END
    lxc-destroy -n $name
    lxc-create -n $name -f $conf_file

done
