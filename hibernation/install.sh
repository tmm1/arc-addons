#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing daemon for hibernation"

  if [ -f /tmpRoot/etc.defaults/syslog-ng/patterndb.d/scemd.conf ]; then
    cp -vfp /tmpRoot/etc.defaults/syslog-ng/patterndb.d/scemd.conf /tmpRoot/etc.defaults/syslog-ng/patterndb.d/scemd.conf.bak
    sed -i 's/destination(d_scemd)/flags(final)/g' /tmpRoot/etc.defaults/syslog-ng/patterndb.d/scemd.conf
  else
    echo "scemd.conf does not exist."
  fi

  if [ -f /tmpRoot/etc.defaults/syslog-ng/patterndb.d/synosystemd.conf ]; then
    cp -vfp /tmpRoot/etc.defaults/syslog-ng/patterndb.d/synosystemd.conf /tmpRoot/etc.defaults/syslog-ng/patterndb.d/synosystemd.conf.bak
    sed -i 's/destination(d_synosystemd)/flags(final)/g; s/destination(d_systemd)/flags(final)/g' /tmpRoot/etc.defaults/syslog-ng/patterndb.d/synosystemd.conf
  else
    echo "synosystemd.conf does not exist."
  fi
fi
