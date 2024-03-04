#!/usr/bin/env ash

MODELS="DS918+ RS1619xs+ DS419+ DS1019+ DS719+ DS1621xs+"
MODEL=$(cat /proc/sys/kernel/syno_hw_version)

if [ "${1}" = "patches" ]; then
  echo "Installing addon nvmecache - ${1}"

  if ! echo ${MODELS} | grep -q ${MODEL}; then
    echo "${MODEL} is not in models"
    exit 0
  fi
  BOOTDISK=""
  BOOTDISK_PART3=$(blkid -L ARC3 | sed 's/\/dev\///')
  [ -n "${BOOTDISK_PART3}" ] && BOOTDISK=$(ls -d /sys/block/*/${BOOTDISK_PART3} 2>/dev/null | cut -d'/' -f4)
  [ -n "${BOOTDISK}" ] && BOOTDISK_PHYSDEVPATH="$(cat /sys/block/${BOOTDISK}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" || BOOTDISK_PHYSDEVPATH=""
  echo "BOOTDISK=${BOOTDISK}"
  echo "BOOTDISK_PHYSDEVPATH=${BOOTDISK_PHYSDEVPATH}"
  rm -f /etc/nvmePorts
  for P in $(ls -d /sys/block/nvme* 2>/dev/null); do
    if [ -n "${BOOTDISK_PHYSDEVPATH}" -a "${BOOTDISK_PHYSDEVPATH}" = "$(cat ${P}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" ]; then
      echo "bootloader: ${P}"
      continue
    fi
    PCIEPATH=$(cat ${P}/uevent 2>/dev/null | grep 'PHYSDEVPATH' | cut -d'/' -f4)
    if [ -n "${PCIEPATH}" ]; then
      # TODO: Need check?
      MULTIPATH=$(cat ${P}/uevent 2>/dev/null | grep 'PHYSDEVPATH' | cut -d'/' -f5)
      if [ -z "${MULTIPATH}" ]; then
        echo "${PCIEPATH} does not support!"
        continue
      fi
      echo "${PCIEPATH}" >>/etc/nvmePorts
    fi
  done
  [ -f /etc/nvmePorts ] && cat /etc/nvmePorts
elif [ "${1}" = "late" ]; then
  echo "Installing addon nvmecache - ${1}"
  mkdir -p "/tmpRoot/usr/arc/addons/"
  cp -vf "${0}" "/tmpRoot/usr/arc/addons/"

  if ! echo ${MODELS} | grep -q ${MODEL}; then
    echo "${MODEL} is not in models"
    exit 0
  fi
  #
  # |       models      |     1st      |     2nd      |
  # | DS918+            | 0000:00:13.1 | 0000:00:13.2 |
  # | RS1619xs+         | 0000:00:03.2 | 0000:00:03.3 |
  # | DS419+, DS1019+   | 0000:00:14.1 |              |
  # | DS719+, DS1621xs+ | 0000:00:01.1 | 0000:00:01.0 |
  #
  # In the late stage, the /sys/ directory does not exist, and the device path cannot be obtained.
  # (/dev/ does exist, but there is no useful information.)
  # (The information obtained by lspci is incomplete and an error will be reported.)
  # Therefore, the device path is obtained in the early stage and stored in /etc/nvmePorts.

  SO_FILE="/tmpRoot/usr/lib/libsynonvme.so.1"
  [ ! -f "${SO_FILE}.bak" ] && cp -vf "${SO_FILE}" "${SO_FILE}.bak"

  cp -vf "${SO_FILE}.bak" "${SO_FILE}"
  # Replace the device path.
  sed -i "s/0000:00:13.1/0000:99:99.0/; s/0000:00:03.2/0000:99:99.0/; s/0000:00:14.1/0000:99:99.0/; s/0000:00:01.1/0000:99:99.0/" "${SO_FILE}"
  sed -i "s/0000:00:13.2/0000:99:99.1/; s/0000:00:03.3/0000:99:99.1/; s/0000:00:99.9/0000:99:99.1/; s/0000:00:01.0/0000:99:99.1/" "${SO_FILE}"

  idx=0
  for N in $(cat /etc/nvmePorts 2>/dev/null); do
    echo "${idx} - ${N}"
    if [ ${idx} -eq 0 ]; then
      sed -i "s/0000:99:99.0/${N}/g" "${SO_FILE}"
    elif [ ${idx} -eq 1 ]; then
      sed -i "s/0000:99:99.1/${N}/g" "${SO_FILE}"
    else
      break
    fi
    idx=$((idx + 1))
  done
elif [ "${1}" = "uninstall" ]; then
  echo "Installing addon nvmecache - ${1}"

  if ! echo ${MODELS} | grep -q ${MODEL}; then
    echo "${MODEL} is not in models"
    exit 0
  fi

  SO_FILE="/tmpRoot/usr/lib/libsynonvme.so.1"
  [ -f "${SO_FILE}.bak" ] && mv -f "${SO_FILE}.bak" "${SO_FILE}"
fi