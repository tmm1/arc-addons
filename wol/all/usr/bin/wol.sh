#!/usr/bin/env bash

for N in $(ls /sys/class/net/ 2>/dev/null | grep eth); do
  echo "set ${N} wol g"
  /usr/bin/ethtool -s "${N}" wol g
done