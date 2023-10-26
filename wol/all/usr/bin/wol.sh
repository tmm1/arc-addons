#!/usr/bin/env bash

for N in $(ls /sys/class/net/ | grep eth); do
  echo "set ${N} wol g"
  /usr/bin/ethtool -s "${N}" wol g
done