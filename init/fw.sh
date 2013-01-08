#!/bin/bash

sbin=$(dirname $0)/../nat-sbin

$sbin/nat-fw.sh $1

exec /bin/bash
