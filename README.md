# Overview #

This project provides a set of scripts for creating a local NAT test
environment in Linux using lxc containers. It uses network only isolation, so
no root filesystems are required. The firewalls use stateful inspection to
allow any outgoing traffic, but only allow incoming traffic that is part
of an established outgoing connection.

The scripts use networks `10.0.3.0/24`, `10.0.1.0/24`, `10.0.2.0/24`,
`10.0.11.0/24`, and `10.0.12.0/24`. If any of these are used by your local
environment, you'll need to change them in each script.

See `lxc-nat.png` for a network diagram. The networks are named after the
interfaces that get created (see `host-sbin/ifaces.sh`). `brpub` is designed to
represent the public internet - testing more complex routing is not the purpose
of this setup, so having a single network that the outer firewalls are
connected to is sufficient.

# Setup #

## Install dependencies ##

First you will need to install [lxc](http://lxc.sourceforge.net/) tools and an
lxc enabled kernel. In debian:

    sudo apt-get install lxc

Make sure your kernel has cgroup support, network namespace, and veth pair
device:

    lxc-checkconfig

Mount the cgroup filesystem:

    sudo mount cgroup -t cgroup /sys/fs/cgroup

to mount at boot, add this to `/etc/fstab`:

    cgroup /sys/fs/cgroup cgroup defaults 0 0

See /usr/share/doc/lxc/README.Debian for details.

The scripts also use iproute2, screen, and iptables:

    sudo apt-get install iproute screen iptables

The iptables scripts use the conntrack module and ctstate target; for older
iptables the scripts can be trivially modified to use the old state module
instead.

## hosts ##

The containers will have hostname equal to the container name. Many network
applications require the hostname to be mapped to an IP to function properly:

    sudo cat hosts >> /etc/hosts

## Create Containers ##

The start container script assumes that lxc has been enabled for non-root
users; see the lxc readme for the security implications. If you don't want to
enable this, edit create-containers.sh and skip the setcap step.

    sudo lxc-setcap
    sudo host-sbin/create-containers.sh

# Run #

Bring up the interfaces and add rules to allow bridge to bridge traffic:

    sudo host-sbin/ifaces.sh
    sudo host-sbin/host-fw.sh

The firewall only creates rules for the new interfaces, so it should not
interfere with any existing rules. Note that if forwarding is allowed by
default traffic may be allowed to/from the new interfaces and existing
interfaces.

Then you can start containers; I recommend using a separate xterm for each:

    host-bin/start-container.sh fw1
    host-bin/start-container.sh client1
    host-bin/start-container.sh fw2
    host-bin/start-container.sh client2

Note that the fwN containers will prompt for a sudo password; they need to
execute a firewall script so root is required. The containers run in screen, so
they can be detached and re-attached from the terminal as needed.

# Debugging #

The firwall script (nat-sbin/nat-fw.sh) has log rules for dropped traffic, with
prefix 'LXC (container name) (IN|OUT|FW) DROP'. They are logged using kern
facility; typical (r)syslog config puts these in /var/log/kern.log. Note that
the network namespace also has separate iptables, so the in container firewall
config will not interfere with the host firewall.
