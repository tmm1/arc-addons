# DSM version
MajorVersion=$(/bin/get_key_value /etc.defaults/VERSION majorversion)
MinorVersion=$(/bin/get_key_value /etc.defaults/VERSION minorversion)

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
  /usr/sbin/depmod -a
  /usr/sbin/udevd -d || {
    echo "FAIL"
    exit 1
  }
  echo "eudev: Triggering add events to udev"
  udevadm trigger --type=subsystems --action=add
  udevadm trigger --type=devices --action=add
  udevadm trigger --type=devices --action=change
  udevadm settle --timeout=30 || echo "eudev: udevadm settle failed"
  # Give more time
  sleep 10
  # Remove from memory to not conflict with RAID mount scripts
  /usr/bin/killall udevd
  # Remove kvm module
  /usr/sbin/lsmod | grep -q ^kvm_intel && /usr/sbin/rmmod kvm_intel || true  # kvm-intel.ko
  /usr/sbin/lsmod | grep -q ^kvm_amd && /usr/sbin/rmmod kvm_amd || true  # kvm-amd.ko
  /usr/sbin/lsmod | grep -q ^kvm && /usr/sbin/rmmod kvm || true
  /usr/sbin/lsmod | grep -q ^irqbypass && /usr/sbin/rmmod irqbypass || true

elif [ "${1}" = "late" ]; then
  echo "Starting eudev daemon - late"

  echo "eudev: copy Modules"
  isChange=0
  export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
  /tmpRoot/bin/cp -rnf /usr/lib/firmware/* /tmpRoot/usr/lib/firmware/
  cat /addons/modulelist 2>/dev/null | /tmpRoot/bin/sed '/^\s*$/d' | while IFS=' ' read -r O M; do
    [ "${O:0:1}" = "#" ] && continue
    [ -z "${M}" -o -z "$(ls /usr/lib/modules/${M} 2>/dev/null)" ] && continue
    if [ "${O}" = "F" ] || [ "${O}" = "f" ]; then
      /tmpRoot/bin/cp -vrf /usr/lib/modules/${M} /tmpRoot/usr/lib/modules/
    else
      /tmpRoot/bin/cp -vrn /usr/lib/modules/${M} /tmpRoot/usr/lib/modules/
    fi
    isChange=1
  done
  [ "${isChange}" = "1" ] && /usr/sbin/depmod -a -b /tmpRoot/

  echo "eudev: copy Rules"
  cp -vf /usr/lib/udev/rules.d/* /tmpRoot/usr/lib/udev/rules.d/
  DEST="/tmpRoot/lib/systemd/system/udevrules.service"
  echo "[Unit]"                                                                  >${DEST}
  echo "Description=Reload udev Rules"                                          >>${DEST}
  echo                                                                          >>${DEST}
  echo "[Service]"                                                              >>${DEST}
  echo "Type=oneshot"                                                           >>${DEST}
  echo "RemainAfterExit=true"                                                   >>${DEST}
  echo "ExecStart=/usr/bin/udevadm hwdb --update"                               >>${DEST}
  echo "ExecStart=/usr/bin/udevadm control --reload-rules"                      >>${DEST}
  echo                                                                          >>${DEST}
  echo "[Install]"                                                              >>${DEST}
  echo "WantedBy=multi-user.target"                                             >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /lib/systemd/system/udevrules.service /tmpRoot/lib/systemd/system/multi-user.target.wants/udevrules.service
fi
