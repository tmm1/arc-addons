#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Disable Out Of Band LAN in DSM"
  if [ -f /tmpRoot/etc/synoinfo.conf ]; then
    echo 'add support_oob_ctl="no" to /tmpRoot/etc/synoinfo.conf'
    if grep -q 'support_oob_ctl' /tmpRoot/etc/synoinfo.conf; then
      sed -i 's#support_oob_ctl=.*#support_oob_ctl="no"#' /tmpRoot/etc/synoinfo.conf
    else
      echo 'support_oob_ctl="no"' >> /tmpRoot/etc/synoinfo.conf
    fi
    cat /tmpRoot/etc/synoinfo.conf | grep support_oob_ctl
  fi

  if [ -f /tmpRoot/etc.defaults/synoinfo.conf ]; then
    echo 'add support_oob_ctl="no" to /tmpRoot/etc.defaults/synoinfo.conf'
    if grep -q 'support_oob_ctl' /tmpRoot/etc.defaults/synoinfo.conf; then
      sed -i 's#support_oob_ctl=.*#support_oob_ctl="no"#' /tmpRoot/etc.defaults/synoinfo.conf
    else
      echo 'support_oob_ctl="no"' >> /tmpRoot/etc.defaults/synoinfo.conf
    fi
    cat /tmpRoot/etc.defaults/synoinfo.conf | grep support_oob_ctl
  fi
fi