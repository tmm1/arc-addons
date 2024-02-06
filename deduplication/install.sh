#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Creating service to exec deduplication"
  cp -vf /usr/sbin/deduplication.sh /tmpRoot/usr/sbin/deduplication.sh
  
  DEST="/tmpRoot/usr/lib/systemd/system/deduplication.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Enable Deduplication"                                     >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/bin/deduplication.sh --tiny"                          >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -vp /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -vsf /usr/lib/systemd/system/deduplication.service /tmpRoot/lib/systemd/system/multi-user.target.wants/deduplication.service
elif [ "${1}" = "uninstall" ]; then
  echo "Installing addon deduplication - ${1}"

  rm -f "/tmpRoot/lib/systemd/system/multi-user.target.wants/deduplication.service"
  rm -f "/tmpRoot/usr/lib/systemd/system/deduplication.service"

  [ ! -f "/tmpRoot/usr/arc/revert.sh" ] && echo '#!/usr/bin/env bash' >/tmpRoot/usr/arc/revert.sh && chmod +x /tmpRoot/usr/arc/revert.sh
  echo "/usr/bin/deduplication.sh --restore" >>/tmpRoot/usr/arc/revert.sh
  echo "rm -f /usr/bin/deduplication.sh" >>/tmpRoot/usr/arc/revert.sh
fi
