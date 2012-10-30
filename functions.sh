
PRIVPORTS="0:1023"                   # well-known, privileged port range
UNPRIVPORTS="1024:65535"             # unprivileged port range

IPT=/sbin/iptables

mkchain() {
    table=$1
    chain=$2
    $IPT -t $table -L $chain >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        $IPT -t $table -N $chain
    else
        $IPT -t $table -F $chain
    fi
}

insertrule() {
    table=$1
    chain=$2
    shift; shift
    $IPT -t $table -C $chain "$@"
    if [ $? -ne 0 ]; then
        $IPT -t $table -I $chain "$@"
    fi
}

ifacenet() {
    iface=$1
    echo $(ip addr show dev $1 | grep '^\s*inet ' | awk '{ print $2 }')
}
