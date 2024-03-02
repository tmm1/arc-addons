#!/usr/bin/env ash

# DSM version
MajorVersion=$(/bin/get_key_value /etc.defaults/VERSION majorversion)
MinorVersion=$(/bin/get_key_value /etc.defaults/VERSION minorversion)

echo "eudev: MajorVersion:${MajorVersion} MinorVersion:${MinorVersion}"

MODULESCOPY="${2}:-false"
echo "disks: modulescopy is ${MODULESCOPY}"
KVMSUPPORT="${3}:-false"
echo "disks: kvmsupport is ${KVMSUPPORT}"

if [ "${1}" = "modules" ]; then
  echo "Installing addon eudev - ${1}"
  if [ "${MinorVersion}" -lt "2" ]; then # < 2
    tar zxf /addons/eudev-7.1.tgz -C /
  else
    tar zxf /addons/eudev-7.2.tgz -C /
  fi
  [ -e /proc/sys/kernel/hotplug ] && printf '\000\000\000\000' >/proc/sys/kernel/hotplug
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
  # Remove KVM Module
  /usr/sbin/lsmod | grep -q ^kvm_intel && /usr/sbin/rmmod kvm_intel || true  # kvm-intel.ko
  /usr/sbin/lsmod | grep -q ^kvm_amd && /usr/sbin/rmmod kvm_amd || true  # kvm-amd.ko
  /usr/sbin/lsmod | grep -q ^kvm && /usr/sbin/rmmod kvm || true
  /usr/sbin/lsmod | grep -q ^irqbypass && /usr/sbin/rmmod irqbypass || true

elif [ "${1}" = "late" ]; then
  echo "Installing addon eudev - ${1}"

  echo "eudev: copy modules"
  isChange="false"
  export LD_LIBRARY_PATH=/tmpRoot/bin:/tmpRoot/lib
  /tmpRoot/bin/cp -rnf /usr/lib/firmware/* /tmpRoot/usr/lib/firmware/
  if cat /proc/version | grep -q 'RR@RR'; then
    if [ -d /tmpRoot/usr/lib/modules.bak ]; then
      /tmpRoot/bin/rm -rf /tmpRoot/usr/lib/modules
      /tmpRoot/bin/cp -rf /tmpRoot/usr/lib/modules.bak /tmpRoot/usr/lib/modules
    else
      echo "eudev: backup modules"
      /tmpRoot/bin/cp -rf /tmpRoot/usr/lib/modules /tmpRoot/usr/lib/modules.bak
    fi
    /tmpRoot/bin/cp -rf /usr/lib/modules/* /tmpRoot/usr/lib/modules
    echo "true" >/tmp/modulesChange
  else
    if [ -d /tmpRoot/usr/lib/modules.bak ]; then
      echo "eudev: restore modules from backup"
      /tmpRoot/bin/rm -rf /tmpRoot/usr/lib/modules
      /tmpRoot/bin/mv -rf /tmpRoot/usr/lib/modules.bak /tmpRoot/usr/lib/modules
    fi
    if [ "${MODULESCOPY}" = "true" ]; then
      echo "eudev: modulescopy is true - copy all modules to DSM"
      /tmpRoot/bin/cp -rf /usr/lib/modules/* /tmpRoot/usr/lib/modules
      echo "true" >/tmp/modulesChange
    else
      echo "eudev: modulescopy is false - only copy needed modules to DSM"
      cat /addons/modulelist 2>/dev/null | /tmpRoot/bin/sed '/^\s*$/d' | while IFS=' ' read -r O M; do
        [ "${O:0:1}" = "#" ] && continue
        [ -z "${M}" -o -z "$(ls /usr/lib/modules/${M} 2>/dev/null)" ] && continue
        if [ "${O}" = "F" ] || [ "${O}" = "f" ]; then
          /tmpRoot/bin/cp -vrf /usr/lib/modules/${M} /tmpRoot/usr/lib/modules/
        else
          /tmpRoot/bin/cp -vrn /usr/lib/modules/${M} /tmpRoot/usr/lib/modules/
        fi
        # isChange="true"
        # In Bash, the pipe operator | creates a subshell to execute the commands in the pipe.
        # This means that if you modify a variable inside a while loop,
        # the modification is not visible outside the loop because the while loop is executed in a subshell.
        echo "true" >/tmp/modulesChange
      done
    fi
  fi
  isChange="$(cat /tmp/modulesChange 2>/dev/null || echo "false")"
  echo "isChange: ${isChange}"
  [ "${isChange}" = "true" ] && /usr/sbin/depmod -a -b /tmpRoot/
  
  # Restore KVM Module if CPU support it
  if [ "${KVMSUPPORT}" = "true" ]; then
    /usr/sbin/insmod /usr/lib/modules/irqbypass.ko || true
    /usr/sbin/insmod /usr/lib/modules/kvm.ko || true
    /usr/sbin/insmod /usr/lib/modules/kvm-intel.ko || true  # kvm-intel.ko
    /usr/sbin/insmod /usr/lib/modules/kvm-amd.ko || true  # kvm-amd.ko
  fi

  echo "eudev: copy Rules"
  cp -vf /usr/lib/udev/rules.d/* /tmpRoot/usr/lib/udev/rules.d/
  #echo "eudev: copy HWDB"
  #mkdir -p /tmpRoot/etc/udev/hwdb.d
  #cp -rf /etc/udev/hwdb.d/* /tmpRoot/etc/udev/hwdb.d/
  
  DEST="/tmpRoot/lib/systemd/system/udevrules.service"
  echo "[Unit]"                                                                  >${DEST}
  echo "Description=Reload udev rules"                                          >>${DEST}
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
