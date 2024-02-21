#!/usr/bin/env bash

ETHX=$(ls /sys/class/net/ 2>/dev/null | grep eth)
for ETH in ${ETHX}; do
  echo "wol: ${ETH} force set wol to g"
  /usr/bin/ethtool -s ${ETH} wol g
done