#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for revert"

  if [ -f /tmpRoot/usr/sbin/revert.sh ]; then
    echo "exec revert.sh"
    chmod +x /tmpRoot/usr/sbin/revert.sh
    /tmpRoot/usr/sbin/revert.sh
    rm -f /tmpRoot/usr/sbin/revert.sh
  fi
  echo "touch revert.sh"
  touch /tmpRoot/usr/sbin/revert.sh
fi