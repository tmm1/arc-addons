#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Script for fixing missing HW features dependencies and another functions"

  # Copy Utilities
  cp -vf /usr/sbin/loader-reboot.sh /tmpRoot/usr/sbin/loader-reboot.sh
  cp -vf /usr/sbin/grub-editenv /tmpRoot/usr/sbin/grub-editenv
  cp -vf /usr/bin/awk /tmpRoot/usr/bin/awk
  cp -vf /usr/bin/bc /tmpRoot/usr/bin/bc
  cp -vf /usr/bin/dtc /tmpRoot/usr/bin/dtc
  cp -vf /usr/bin/ethtool /tmpRoot/usr/bin/ethtool
  cp -vf /usr/bin/jq /tmpRoot/usr/bin/jq
  cp -vf /usr/bin/kmod /tmpRoot/usr/bin/kmod
  cp -vf /usr/bin/less /tmpRoot/usr/bin/less
  cp -vf /usr/bin/lessecho /tmpRoot/usr/bin/lessecho
  cp -vf /usr/bin/lspci /tmpRoot/usr/bin/lspci
  cp -vf /usr/bin/readlink /tmpRoot/usr/bin/readlink
  cp -vf /usr/bin/sed /tmpRoot/usr/bin/sed
  cp -vf /usr/bin/sort /tmpRoot/usr/bin/sort
  cp -vf /usr/bin/tr /tmpRoot/usr/bin/tr
  cp -vf /usr/bin/xxd /tmpRoot/usr/bin/xxd

  SED_PATH='/tmpRoot/usr/bin/sed'
  XXD_PATH='/tmpRoot/usr/bin/xxd'
  LSPCI_PATH='/tmpRoot/usr/bin/lspci'

  mount -t sysfs sysfs /sys
  modprobe processor
  modprobe acpi-cpufreq
  # CPU performance scaling
  if [ -f /tmpRoot/usr/lib/modules-load.d/70-cpufreq-kernel.conf ]; then
    cpufreq=$(ls -ltr /sys/devices/system/cpu/cpufreq/* 2>/dev/null | wc -l)
    if [ $cpufreq -eq 0 ]; then
      echo "CPU does NOT support CPU Performance Scaling, disabling"
      ${SED_PATH} -i 's/^acpi-cpufreq/# acpi-cpufreq/g' /tmpRoot/usr/lib/modules-load.d/70-cpufreq-kernel.conf
    else
      echo "CPU supports CPU Performance Scaling, enabling"
      ${SED_PATH} -i 's/^# acpi-cpufreq/acpi-cpufreq/g' /tmpRoot/usr/lib/modules-load.d/70-cpufreq-kernel.conf
    fi
  fi
  umount /sys

  # crypto-kernel
  if [ -f /tmpRoot/usr/lib/modules-load.d/70-crypto-kernel.conf ]; then
    # crc32c-intel
    CPUFLAGS=$(cat /proc/cpuinfo | grep flags | grep sse4_2 | wc -l)
    if [ ${CPUFLAGS} -gt 0 ]; then
      echo "CPU Supports SSE4.2, crc32c-intel should load"
    else
      echo "CPU does NOT support SSE4.2, crc32c-intel will not load, disabling"
      ${SED_PATH} -i 's/^crc32c-intel/# crc32c-intel/g' /tmpRoot/usr/lib/modules-load.d/70-crypto-kernel.conf
    fi

    # aesni-intel
    CPUFLAGS=$(cat /proc/cpuinfo | grep flags | grep aes | wc -l)
    if [ ${CPUFLAGS} -gt 0 ]; then
      echo "CPU Supports AES, aesni-intel should load"
    else
      echo "CPU does NOT support AES, aesni-intel will not load, disabling"
      ${SED_PATH} -i 's/support_aesni_intel="yes"/support_aesni_intel="no"/' /tmpRoot/etc.defaults/synoinfo.conf
      ${SED_PATH} -i 's/^aesni-intel/# aesni-intel/g' /tmpRoot/usr/lib/modules-load.d/70-crypto-kernel.conf
    fi
  fi

  # Nvidia GPU
  if [ -f /tmpRoot/usr/lib/modules-load.d/70-syno-nvidia-gpu.conf ]; then
    NVIDIADEV=$(cat /proc/bus/pci/devices | grep -i 10de | wc -l)
    if [ ${NVIDIADEV} -eq 0 ]; then
      echo "NVIDIA GPU is not detected, disabling "
      ${SED_PATH} -i 's/^nvidia/# nvidia/g' /tmpRoot/usr/lib/modules-load.d/70-syno-nvidia-gpu.conf
      ${SED_PATH} -i 's/^nvidia-uvm/# nvidia-uvm/g' /tmpRoot/usr/lib/modules-load.d/70-syno-nvidia-gpu.conf
    else
      echo "NVIDIA GPU is detected, nothing to do"
    fi
  fi

  # Open-VM-Tools-Fix
  if [ -d /tmpRoot/var/packages/open-vm-tools ]; then
    ${SED_PATH} -i 's/package/root/g' /tmpRoot/var/packages/open-vm-tools/conf/privilege
  fi
  if [ -d /var/packages/open-vm-tools ]; then
    ${SED_PATH} -i 's/package/root/g' /var/packages/open-vm-tools/conf/privilege
  fi

  # Network
  rm -vf /tmpRoot/usr/lib/modules-load.d/70-network*.conf
  for I in $(seq 0 7); do
    if [ -f "/etc/sysconfig/network-scripts/ifcfg-eth${I}" ] && [ ! -f "/tmpRoot/etc.defaults/sysconfig/network-scripts/ifcfg-eth${I}" ]; then
      cp -vf "/etc/sysconfig/network-scripts/ifcfg-eth${I}" "/tmpRoot/etc.defaults/sysconfig/network-scripts/ifcfg-eth${I}"
    fi
  done
fi
