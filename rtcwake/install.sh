#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing addon rtcwake"
  cp -vf /usr/sbin/rtcwake /tmpRoot/usr/sbin/rtcwake
fi
