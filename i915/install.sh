#!/usr/bin/env ash

# PLATFORMS="apollolake geminilake"
# PLATFORM=$(/bin/get_key_value /etc.defaults/synoinfo.conf unique | cut -d"_" -f2)
# if ! echo ${PLATFORM} | grep -q ${PLATFORM}; then
#   echo "${PLATFORM} is not supported"
#   exit 0
# fi

if [ "${1}" = "patches" ]; then
  echo "Installing daemon for i915 patches"
  if [ -n "${2}" ]; then
    GPU="$(echo "${2}" | sed 's/://g' | tr '[:upper:]' '[:lower:]')"
  else
    GPU="$(lspci -n | grep 0300 | grep 8086 | cut -d " " -f 3 | sed 's/://g')"
  fi
  [ -z "${GPU}" -o $(echo -n "${GPU}" | wc -c) -ne 8 ] && echo "GPU is not detected" && exit 0
  [ ! -f "/usr/lib/modules/i915.ko" ] && echo "i915.ko does not exist" && exit 0

  if [ -n "${2}" ] || grep -iq ${GPU} /usr/bin/i915ids 2>/dev/null; then
    isLoad=0
    if lsmod | grep -q ^i915; then
      isLoad=1
      rmmod i915
    fi
    GPU_DEF="86800000923e0000"
    GPU_BIN="${GPU:2:2}${GPU:0:2}0000${GPU:6:2}${GPU:4:2}0000"
    echo "GPU:${GPU} GPU_BIN:${GPU_BIN}"
    cp -vf "/usr/lib/modules/i915.ko" "/usr/lib/modules/i915.ko.bak"
    sed -i "s/${GPU_DEF}/${GPU_BIN}/; s/308201f706092a86.*70656e6465647e0a//" "/usr/lib/modules/i915.ko"
    [ "${isLoad}" = "1" ] && /usr/sbin/modprobe "/usr/lib/modules/i915.ko"
  fi
elif [ "${1}" = "late" ]; then
  echo "Installing daemon for i915 late"

  KO_FILE="/tmpRoot/usr/lib/modules/i915.ko"
  [ ! -f "${KO_FILE}.bak" ] && cp -vf "${KO_FILE}" "${KO_FILE}.bak"
  cp -vf "/usr/lib/modules/i915.ko" "${KO_FILE}"
fi