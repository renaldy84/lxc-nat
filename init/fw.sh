#!/bin/bash

sbin=$(dirname $0)/../nat-sbin

$sbin/nat-fw.sh

exec /bin/bash
