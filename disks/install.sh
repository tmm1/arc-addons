#!/usr/bin/env ash
#
# Copyright (C) 2023 AuxXxilium <https://github.com/AuxXxilium> and Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Get values in synoinfo.conf K=V file
# 1 - key
function _get_conf_kv() {
  grep "${1}=" /etc/synoinfo.conf | sed "s|^${1}=\"\(.*\)\"$|\1|g"
}

# Replace/add values in synoinfo.conf K=V file
# Args: $1 rd|hd, $2 key, $3 val
function _set_conf_kv() {
  local ROOT
  local FILE
  [ "$1" = "rd" ] && ROOT="" || ROOT="/tmpRoot"
  for SD in etc etc.defaults; do
    FILE="${ROOT}/${SD}/synoinfo.conf"
    # Replace
    if grep -q "^$2=" ${FILE}; then
      sed -i ${FILE} -e "s\"^$2=.*\"$2=\\\"$3\\\"\""
    else
      # Add if doesn't exist
      echo "$2=\"$3\"" >>${FILE}
    fi
  done
}

# Check if the user has customized the key
# Args: $1 rd|hd, $2 key
function _check_post_k() {
  local ROOT
  [ "$1" = "rd" ] && ROOT="" || ROOT="/tmpRoot"
  if grep -q -r "^_set_conf_kv.*${2}.*" "${ROOT}/sbin/init.post"; then
    return 0 # true
  else
    return 1 # false
  fi
}

# Check if the raid has been completed currently
function _check_rootraidstatus() {
  if [ ! "$(_get_conf_kv supportraid)" = "yes" ]; then
    return 0
  fi
  STATE=$(cat /sys/block/md0/md/array_state 2>/dev/null)
  if [ $? -ne 0 ]; then
    return 1
  fi
  case ${STATE} in
  "clear" | "inactive" | "suspended " | "readonly" | "read-auto")
    return 1
    ;;
  esac
  return 0
}

function _atoi() {
  DISKNAME=${1}
  NUM=0
  IDX=0
  while [ ${IDX} -lt ${#DISKNAME} ]; do
    N=$(($(printf '%d' "'${DISKNAME:${IDX}:1}") - $(printf '%d' "'a") + 1))
    BIT=$((${#DISKNAME} - 1 - ${IDX}))
    [ ${BIT} -eq 0 ] && NUM=$((${NUM} + ${N})) || NUM=$((${NUM} + 26 ** ${BIT} * ${N}))
    IDX=$((${IDX} + 1))
  done
  echo $((${NUM} - 1))
}

# Generate linux kernel version code
# ex.
#   KernelVersionCode "2.4.22"  => 132118
#   KernelVersionCode "2.6"     => 132608
#   KernelVersionCode "2.6.32"  => 132640
#   KernelVersionCode "3"       => 196608
#   KernelVersionCode "3.0.0"   => 196608
function _kernelVersionCode() {
  [ $# -eq 1 ] || return

  local _version_string _major_version _minor_version _revision
  _version_string="$(echo "$1" | /usr/bin/cut -d'_' -f1)."
  _major_version=$(echo "${_version_string}" | /usr/bin/cut -d'.' -f1)
  _minor_version=$(echo "${_version_string}" | /usr/bin/cut -d'.' -f2)
  _revision=$(echo "${_version_string}" | /usr/bin/cut -d'.' -f3)

  /bin/echo $((${_major_version:-0} * 65536 + ${_minor_version:-0} * 256 + ${_revision:-0}))
}

# Get current linux kernel version without extra version
# format: VERSION.PATCHLEVEL.SUBLEVEL
# ex. "2.6.32"
function _kernelVersion() {
  local _release
  _release=$(/bin/uname -r)
  /bin/echo ${_release%%[-+]*} | /usr/bin/cut -d'.' -f1-3
}

# synoboot
function checkSynoboot() {
  [ -b /dev/synoboot -a -b /dev/synoboot1 -a -b /dev/synoboot2 -a -b /dev/synoboot3 ] && return
  [ -z "${BOOTDISK}" ] && return

  if [ ! -b /dev/synoboot -a -d /sys/block/${BOOTDISK} ]; then
    /bin/mknod /dev/synoboot b $(cat /sys/block/${BOOTDISK}/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}
  fi
  # sataN, nvmeXnN, mmcblkN
  if [ ! -b /dev/synoboot1 -a -d /sys/block/${BOOTDISK}/${BOOTDISK}p1 ]; then
    /bin/mknod /dev/synoboot1 b $(cat /sys/block/${BOOTDISK}/${BOOTDISK}p1/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}p1
  fi
  if [ ! -b /dev/synoboot2 -a -d /sys/block/${BOOTDISK}/${BOOTDISK}p2 ]; then
    /bin/mknod /dev/synoboot2 b $(cat /sys/block/${BOOTDISK}/${BOOTDISK}p2/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}p2
  fi
  if [ ! -b /dev/synoboot3 -a -d /sys/block/${BOOTDISK}/${BOOTDISK}p3 ]; then
    /bin/mknod /dev/synoboot3 b $(cat /sys/block/${BOOTDISK}/${BOOTDISK}p3/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}p3
  fi
  # sdN, vdN
  if [ ! -b /dev/synoboot1 -a -d /sys/block/${BOOTDISK}/${BOOTDISK}1 ]; then
    /bin/mknod /dev/synoboot1 b $(cat /sys/block/${BOOTDISK}/${BOOTDISK}1/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}1
  fi
  if [ ! -b /dev/synoboot2 -a -d /sys/block/${BOOTDISK}/${BOOTDISK}2 ]; then
    /bin/mknod /dev/synoboot2 b $(cat /sys/block/${BOOTDISK}/${BOOTDISK}2/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}2
  fi
  if [ ! -b /dev/synoboot3 -a -d /sys/block/${BOOTDISK}/${BOOTDISK}3 ]; then
    /bin/mknod /dev/synoboot3 b $(cat /sys/block/${BOOTDISK}/${BOOTDISK}3/dev | sed 's/:/ /') >/dev/null 2>&1
    rm -vf /dev/${BOOTDISK}3
  fi
}

# USB ports
function getUsbPorts() {
  for I in $(ls -d /sys/bus/usb/devices/usb* 2>/dev/null); do
    # ROOT
    DCLASS=$(cat ${I}/bDeviceClass)
    [ ! "${DCLASS}" = "09" ] && continue
    SPEED=$(cat ${I}/speed)
    [ ${SPEED} -lt 480 ] && continue
    RBUS=$(cat ${I}/busnum)
    RCHILDS=$(cat ${I}/maxchild)
    HAVE_CHILD=0
    for C in $(seq 1 ${RCHILDS}); do
      SUB="${RBUS}-${C}"
      if [ -d "${I}/${SUB}" ]; then
        DCLASS=$(cat ${I}/${SUB}/bDeviceClass)
        [ ! "${DCLASS}" = "09" ] && continue
        [ "${USBMOUNT}" = "false" ] && [ "${DCLASS}" = "08" ] && continue
        SPEED=$(cat ${I}/${SUB}/speed)
        [ ${SPEED} -lt 480 ] && continue
        CHILDS=$(cat ${I}/${SUB}/maxchild)
        HAVE_CHILD=1
        for N in $(seq 1 ${CHILDS}); do
          echo -n "${RBUS}-${C}.${N} "
        done
      fi
    done
    if [ ${HAVE_CHILD} -eq 0 ]; then
      for N in $(seq 1 ${RCHILDS}); do
        echo -n "${RBUS}-${N} "
      done
    fi
  done
  echo
}

#
function dtModel() {
  DEST="/addons/model.dts"
  UNIQUE=$(_get_conf_kv unique)
  if [ ! -f "${DEST}" ]; then # Users can put their own dts.
    echo "/dts-v1/;" >${DEST}
    echo "/ {" >>${DEST}
    echo "    compatible = \"Synology\";" >>${DEST}
    echo "    model = \"${UNIQUE}\";" >>${DEST}
    echo "    version = <0x01>;" >>${DEST}

    # NVME power_limit
    POWER_LIMIT=""
    NVME_PORTS=$(ls /sys/class/nvme 2>/dev/null | wc -w)
    for I in $(seq 0 $((${NVME_PORTS} - 1))); do
      [ ${I} -eq 0 ] && POWER_LIMIT="100" || POWER_LIMIT="${POWER_LIMIT},100"
    done
    if [ -n "${POWER_LIMIT}" ]; then
      echo "    power_limit = \"${POWER_LIMIT}\";" >>${DEST}
    fi
    if [ ${NVME_PORTS} -gt 0 ]; then
      _set_conf_kv rd "supportnvme" "yes"
      _set_conf_kv rd "support_m2_pool" "yes"
    fi
    # SATA ports
    if [ "${HDDSORT}" = "true" ]; then
      I=1
      for P in $(lspci -d ::106 2>/dev/null | cut -d' ' -f1); do
        HOSTNUM=$(ls -l /sys/class/scsi_host 2>/dev/null | grep ${P} | wc -l)
        PCIPATH=""
        for Q in $(ls -l /sys/class/scsi_host 2>/dev/null | grep ${P} | head -1 | grep -oE ":..\.."); do PCIPATH="${PCIPATH},${Q//:/}"; done
        [ -z "${PCIPATH}" ] && continue
        if [ "$(_kernelVersionCode "$(_kernelVersion)")" -ge "$(_kernelVersionCode "5.10")" ]; then
          PCIPATH="0000:00:${PCIPATH:1}" # 5.10+ kernel  TODO: check 0000
        else
          PCIPATH="00:${PCIPATH:1}" # 5.10- kernel
        fi

        IDX=""
        if [ -n "${BOOTDISK_PHYSDEVPATH}" ] && echo "${BOOTDISK_PHYSDEVPATH}" | grep -q "${P}"; then
          IDX=$(ls -l /sys/class/scsi_host 2>/dev/null | grep ${P} | sort -V | grep -n "${BOOTDISK_PHYSDEVPATH%%target*}" | head -1 | cut -d: -f1)
          if [ -n "${IDX}" ] && echo "${IDX}" | grep -q -E '^[0-9]+$'; then if [ ${IDX} -gt 0 ]; then IDX=$((${IDX} - 1)); else IDX="0"; fi; else IDX=""; fi
          echo "bootloader: PCIPATH:${PCIPATH}; IDX:${IDX}"
        fi

        for J in $(seq 0 $((${HOSTNUM} - 1))); do
          [ "${J}" = "${IDX}" ] && continue
          echo "    internal_slot@${I} {" >>${DEST}
          echo "        protocol_type = \"sata\";" >>${DEST}
          echo "        ahci {" >>${DEST}
          echo "            pcie_root = \"${PCIPATH}\";" >>${DEST}
          echo "            ata_port = <0x$(printf '%02X' ${J})>;" >>${DEST}
          echo "        };" >>${DEST}
          echo "    };" >>${DEST}
          I=$((${I} + 1))
        done
      done
      # 100 = SCSI, 104 = RAID, 107 = HBA
      for P in $(lspci -d ::107 2>/dev/null | cut -d' ' -f1) $(lspci -d ::104 2>/dev/null | cut -d' ' -f1) $(lspci -d ::100 2>/dev/null | cut -d' ' -f1); do
        J=1
        while true; do
          [ ! -d /sys/block/sata${J} ] && break
          if cat /sys/block/sata${J}/uevent | grep 'PHYSDEVPATH' | grep -q "${P}"; then
            if [ -n "${BOOTDISK_PHYSDEVPATH}" -a "${BOOTDISK_PHYSDEVPATH}" = "$(cat /sys/block/sata${J}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" ]; then
              echo "bootloader: /sys/block/sata${J}"
            else
              PCIEPATH=$(grep 'pciepath' /sys/block/sata${J}/device/syno_block_info 2>/dev/null | cut -d'=' -f2)
              ATAPORT=$(grep 'ata_port_no' /sys/block/sata${J}/device/syno_block_info 2>/dev/null | cut -d'=' -f2)
              if [ -n "${PCIEPATH}" -a -n "${ATAPORT}" ]; then
                echo "    internal_slot@${I} {" >>${DEST}
                echo "        protocol_type = \"sata\";" >>${DEST}
                echo "        ahci {" >>${DEST}
                echo "            pcie_root = \"${PCIEPATH}\";" >>${DEST}
                echo "            ata_port = <0x$(printf '%02X' ${ATAPORT})>;" >>${DEST}
                echo "        };" >>${DEST}
                echo "    };" >>${DEST}
                I=$((${I} + 1))
              fi
            fi
          fi
          J=$((${J} + 1))
        done
      done
    else
      I=1
      J=1
      while true; do
        [ ! -d /sys/block/sata${J} ] && break
        if [ -n "${BOOTDISK_PHYSDEVPATH}" -a "${BOOTDISK_PHYSDEVPATH}" = "$(cat /sys/block/sata${J}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" ]; then
          echo "bootloader: /sys/block/sata${J}"
        else
          PCIEPATH=$(grep 'pciepath' /sys/block/sata${J}/device/syno_block_info 2>/dev/null | cut -d'=' -f2)
          ATAPORT=$(grep 'ata_port_no' /sys/block/sata${J}/device/syno_block_info 2>/dev/null | cut -d'=' -f2)
          if [ -n "${PCIEPATH}" -a -n "${ATAPORT}" ]; then
            echo "    internal_slot@${I} {" >>${DEST}
            echo "        protocol_type = \"sata\";" >>${DEST}
            echo "        ahci {" >>${DEST}
            echo "            pcie_root = \"${PCIEPATH}\";" >>${DEST}
            echo "            ata_port = <0x$(printf '%02X' ${ATAPORT})>;" >>${DEST}
            echo "        };" >>${DEST}
            echo "    };" >>${DEST}
            I=$((${I} + 1))
          fi
        fi
        J=$((${J} + 1))
      done
    fi
    NUMPORTS=$((${I} - 1))
    # Raidtool will read maxdisks, but when maxdisks is greater than 27, formatting error will occur 8%.
    if ! _check_rootraidstatus && [ ${NUMPORTS} -gt 26 ]; then
      NUMPORTS=26
    elif ! _check_rootraidstatus && [ ${NUMPORTS} -le 4 ]; then
      NUMPORTS=4
    fi
    _set_conf_kv rd "maxdisks" "${NUMPORTS}"
    echo "maxdisks=${NUMPORTS}"

    # NVME ports
    COUNT=1
    for P in $(ls -d /sys/block/nvme* 2>/dev/null); do
      if [ -n "${BOOTDISK_PHYSDEVPATH}" -a "${BOOTDISK_PHYSDEVPATH}" = "$(cat ${P}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" ]; then
        echo "bootloader: ${P}"
        continue
      fi
      PCIEPATH=$(grep 'pciepath' ${P}/device/syno_block_info 2>/dev/null | cut -d'=' -f2)
      if [ -n "${PCIEPATH}" ]; then
        echo "    nvme_slot@${COUNT} {" >>${DEST}
        echo "        pcie_root = \"${PCIEPATH}\";" >>${DEST}
        echo "        port_type = \"ssdcache\";" >>${DEST}
        echo "    };" >>${DEST}
        COUNT=$((${COUNT} + 1))
      fi
    done

    # USB ports
    COUNT=1
    for I in $(getUsbPorts); do
      echo "    usb_slot@${COUNT} {" >>${DEST}
      echo "      usb2 {" >>${DEST}
      echo "        usb_port =\"${I}\";" >>${DEST}
      echo "      };" >>${DEST}
      echo "      usb3 {" >>${DEST}
      echo "        usb_port =\"${I}\";" >>${DEST}
      echo "      };" >>${DEST}
      echo "    };" >>${DEST}
      COUNT=$((${COUNT} + 1))
    done
    echo "};" >>${DEST}
  fi
  dtc -I dts -O dtb ${DEST} >/etc/model.dtb
  cp -vf /etc/model.dtb /run/model.dtb
  /usr/syno/bin/syno_slot_mapping
}

function nondtModel() {
  MAXDISKS=0
  USBPORTCFG=0
  ESATAPORTCFG=0
  INTERNALPORTCFG=0
  # 100 = SCSI, 104 = RAID, 107 = HBA
  HBA_NUMBER=$(($(lspci -d ::107 2>/dev/null | wc -l) + $(lspci -d ::104 2>/dev/null | wc -l) + $(lspci -d ::100 2>/dev/null | wc -l)))

  for I in $(ls -d /sys/block/sd* 2>/dev/null); do
    IDX=$(_atoi ${I/\/sys\/block\/sd/})
    ISUSB="$(cat ${I}/uevent 2>/dev/null | grep PHYSDEVPATH | grep usb)"
    [ -n "${ISUSB}" ] && USBPORTCFG=$((${USBPORTCFG} | $((1 << ${IDX}))))
    if [ "${USBMOUNT}" = "true" ] || [ ! -n "${ISUSB}" ]; then
      [ $((${IDX} + 1)) -ge ${MAXDISKS} ] && MAXDISKS=$((${IDX} + 1))
    fi
  done

  if _check_post_k "rd" "maxdisks"; then
    MAXDISKS=$(($(_get_conf_kv maxdisks)))
    echo "get maxdisks=${MAXDISKS}"
  fi

  # Raidtool will read maxdisks, but when maxdisks is greater than 27, formatting error will occur 8%.
  if ! _check_rootraidstatus && [ ${MAXDISKS} -gt 26 ]; then
    MAXDISKS=26
  elif ! _check_rootraidstatus && [ ${MAXDISKS} -le 4 ]; then
    MAXDISKS=4
  fi

  if _check_post_k "rd" "usbportcfg"; then
    USBPORTCFG=$(($(_get_conf_kv usbportcfg)))
    echo "get usbportcfg=${USBPORTCFG}"
  else
    _set_conf_kv rd "usbportcfg" "$(printf '0x%.2x' ${USBPORTCFG})"
    echo "set usbportcfg=${USBPORTCFG}"
  fi
  if _check_post_k "rd" "esataportcfg"; then
    ESATAPORTCFG=$(($(_get_conf_kv esataportcfg)))
    echo "get esataportcfg=${ESATAPORTCFG}"
  else
    _set_conf_kv rd "esataportcfg" "$(printf "0x%.2x" ${ESATAPORTCFG})"
    echo "set esataportcfg=${ESATAPORTCFG}"
  fi
  if _check_post_k "rd" "internalportcfg"; then
    INTERNALPORTCFG=$(($(_get_conf_kv internalportcfg)))
    echo "get internalportcfg=${INTERNALPORTCFG}"
  else
    if [ "${USBMOUNT}" = "true" ]; then
      INTERNALPORTCFG=$(($((2 ** ${MAXDISKS} - 1)) ^ ${USBPORTCFG} ^ ${ESATAPORTCFG}))
    else
      INTERNALPORTCFG=$((2 ** ${MAXDISKS} - 1))
    fi
  fi

  _set_conf_kv rd "maxdisks" "${MAXDISKS}"
  echo "set maxdisks=${MAXDISKS}"

  if [ "${HDDSORT}" = "true" ]; then
    echo "TODO: no-DT's sort!!!"
  fi

  # NVME
  COUNT=1
  echo "[pci]" >/etc/extensionPorts
  for P in $(ls -d /sys/block/nvme* 2>/dev/null); do
    if [ -n "${BOOTDISK_PHYSDEVPATH}" -a "${BOOTDISK_PHYSDEVPATH}" = "$(cat ${P}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" ]; then
      echo "bootloader: ${P}"
      continue
    fi
    PCIEPATH=$(cat ${P}/uevent 2>/dev/null | grep 'PHYSDEVPATH' | cut -d'/' -f4)
    if [ -n "${PCIEPATH}" ]; then
      # TODO: Need check?
      # MULTIPATH=$(cat ${P}/uevent 2>/dev/null | grep 'PHYSDEVPATH' | cut -d'/' -f5)
      # if [ -z "${MULTIPATH}" ]; then
      #   echo "${PCIEPATH} does not support!"
      #   continue
      # fi
      echo "pci${COUNT}=\"${PCIEPATH}\"" >>/etc/extensionPorts
      COUNT=$((${COUNT} + 1))

      _set_conf_kv rd "supportnvme" "yes"
      _set_conf_kv rd "support_m2_pool" "yes"
    fi
  done
}

#
if [ "${1}" = "patches" ]; then
  echo "Installing addon disks - ${1}"
  HDDSORT="${2:false}"
  echo "disks: hddsort is ${HDDSORT}" 
  USBMOUNT="${3:false}"
  echo "disks: usbmount is ${USBMOUNT}"
  BOOTDISK=""
  BOOTDISK_PART3=$(blkid -L ARC3 | sed 's/\/dev\///')
  [ -n "${BOOTDISK_PART3}" ] && BOOTDISK=$(ls -d /sys/block/*/${BOOTDISK_PART3} 2>/dev/null | cut -d'/' -f4)
  [ -n "${BOOTDISK}" ] && BOOTDISK_PHYSDEVPATH="$(cat /sys/block/${BOOTDISK}/uevent | grep 'PHYSDEVPATH' | cut -d'=' -f2)" || BOOTDISK_PHYSDEVPATH=""
  echo "BOOTDISK=${BOOTDISK}"
  echo "BOOTDISK_PHYSDEVPATH=${BOOTDISK_PHYSDEVPATH}"
  checkSynoboot

  [ "$(_get_conf_kv supportportmappingv2)" = "yes" ] && dtModel || nondtModel

elif [ "${1}" = "late" ]; then
  echo "Installing addon disks - ${1}"
  if [ "$(_get_conf_kv supportportmappingv2)" = "yes" ]; then
    echo "Copying /etc.defaults/model.dtb"
    # copy file
    cp -vf /etc/model.dtb /tmpRoot/etc/model.dtb
    cp -vf /etc/model.dtb /tmpRoot/etc.defaults/model.dtb
  else
    echo "Adjust maxdisks and internalportcfg automatically"
    # sysfs is unpopulated here, get the values from junior synoinfo.conf
    MAXDISKS=$(_get_conf_kv maxdisks)
    USBPORTCFG=$(_get_conf_kv usbportcfg)
    ESATAPORTCFG=$(_get_conf_kv esataportcfg)
    INTERNALPORTCFG=$(_get_conf_kv internalportcfg)
    # log
    echo "maxdisks=${MAXDISKS}"
    echo "usbportcfg=${USBPORTCFG}"
    echo "esataportcfg=${ESATAPORTCFG}"
    echo "internalportcfg=${INTERNALPORTCFG}"
    # set
    _set_conf_kv hd "maxdisks" "${MAXDISKS}"
    _set_conf_kv hd "usbportcfg" "${USBPORTCFG}"
    _set_conf_kv hd "esataportcfg" "${ESATAPORTCFG}"
    _set_conf_kv hd "internalportcfg" "${INTERNALPORTCFG}"
    # nvme
    cp -vf /etc/extensionPorts /tmpRoot/etc/extensionPorts
    cp -vf /etc/extensionPorts /tmpRoot/etc.defaults/extensionPorts
  fi

  SUPPORTNVME=$(_get_conf_kv supportnvme)
  SUPPORT_M2_POOL=$(_get_conf_kv support_m2_pool)
  _set_conf_kv hd "supportnvme" "${SUPPORTNVME}"
  _set_conf_kv hd "support_m2_pool" "${SUPPORT_M2_POOL}"
fi
