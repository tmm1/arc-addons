#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Installing addon addincards - ${1}"
  mkdir -p "/tmpRoot/usr/arc/addons/"
  cp -vf "${0}" "/tmpRoot/usr/arc/addons/"

  MODEL="$(cat /proc/sys/kernel/syno_hw_version)"
  FILE="/tmpRoot/usr/syno/etc.defaults/adapter_cards.conf"

  [ ! -f "${FILE}.bak" ] && cp -f "${FILE}" "${FILE}.bak"
  echo -n "" >"${FILE}"
  for N in $(cat "${FILE}.bak" | grep '\['); do
    echo "${N}" >>"${FILE}"
    echo "${MODEL}=yes" >>"${FILE}"
  done
elif [ "${1}" = "uninstall" ]; then
  echo "Installing addon addincards - ${1}"

  FILE="/tmpRoot/usr/syno/etc.defaults/adapter_cards.conf"
  [ -f "${FILE}.bak" ] && mv -f "${FILE}.bak" "${FILE}"
fi
