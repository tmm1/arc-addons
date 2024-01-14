#!/usr/bin/env ash

# DSM version
MajorVersion=$(/bin/get_key_value /etc.defaults/VERSION majorversion)
MinorVersion=$(/bin/get_key_value /etc.defaults/VERSION minorversion)
ModuleUnique=$(/bin/get_key_value /etc.defaults/VERSION unique) # Avoid confusion with global variables

echo "eudev: MajorVersion:${MajorVersion} MinorVersion:${MinorVersion}"

if [ "${1}" = "modules" ]; then
  echo "Starting eudev daemon - modules"
  if [ "${MinorVersion}" -lt "2" ]; then # < 2
    tar zxf /addons/eudev-7.1.tgz -C /
  else
    tar zxf /addons/eudev-7.2.tgz -C /
  fi
  [ -e /proc/sys/kernel/hotplug ] && printf '\000\000\000\000' >/proc/sys/kernel/hotplug
  chmod 755 /usr/sbin/udevd /usr/bin/kmod /usr/bin/udevadm /usr/lib/udev/*
  cp -f /etc/udev/hwdb.bin /usr/lib/udev/hwdb.bin
  /usr/sbin/depmod -a
  /usr/sbin/udevd -d || {
    echo "FAIL"
    exit 1
  }
  echo "Triggering add events to udev"
  udevadm trigger --type=subsystems --action=add
  udevadm trigger --type=devices --action=add
  udevadm trigger --type=devices --action=change
  udevadm settle --timeout=30 || echo "udevadm settle failed"
  # Give more time
  sleep 10
  # Remove from memory to not conflict with RAID mount scripts
  /usr/bin/killall udevd
elif [ "${1}" = "late" ]; then
  echo "Starting eudev daemon - late"
  # The modules of SA6400 still have compatibility issues, temporarily canceling the copy. TODO: to be resolved
  if [ ! "${ModuleUnique}" = "synology_epyc7002_sa6400" ]; then
    echo "eudev: copy firmware and modules"
    export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
    /tmpRoot/bin/cp -rnf /usr/lib/firmware/* /tmpRoot/usr/lib/firmware/
    /tmpRoot/bin/cp -rnf /usr/lib/modules/* /tmpRoot/usr/lib/modules/
    /usr/sbin/depmod -a -b /tmpRoot/
  else
    echo "eudev: copy firmware"
    export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
    /tmpRoot/bin/cp -rnf /usr/lib/modules/* /tmpRoot/usr/lib/modules/
  fi
  echo "eudev: Copy rules"
  cp -vf /usr/lib/udev/rules.d/* /tmpRoot/usr/lib/udev/rules.d/
  mkdir -p /tmpRoot/etc/udev
  cp -vf /etc/udev/hwdb.bin /tmpRoot/etc/udev/hwdb.bin
  mkdir -p /tmpRoot/lib/udev
  cp -vf /etc/udev/hwdb.bin /tmpRoot/usr/lib/udev/hwdb.bin
  [ -f "/tmpRoot/lib/systemd/system/udevrules.service" ] && rm -f "/tmpRoot/lib/systemd/system/udevrules.service"
  DEST="/tmpRoot/lib/systemd/system/udevrules.service"
  echo "[Unit]"                                                                  >${DEST}
  echo "Description=Reload udev rules"                                          >>${DEST}
  echo                                                                          >>${DEST}
  echo "[Service]"                                                              >>${DEST}
  echo "Type=oneshot"                                                           >>${DEST}
  echo "RemainAfterExit=true"                                                   >>${DEST}
  echo "ExecStart=/usr/bin/udevadm control --reload-rules"                      >>${DEST}
  echo                                                                          >>${DEST}
  echo "[Install]"                                                              >>${DEST}
  echo "WantedBy=multi-user.target"                                             >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/udevrules.service /tmpRoot/lib/systemd/system/multi-user.target.wants/udevrules.service
fi
