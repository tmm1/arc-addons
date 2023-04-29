#!/usr/bin/env ash

if [ "${1}" = "jrExit" ]; then
  /usr/bin/nvmecache.sh 2>/dev/null
elif [ "${1}" = "late" ]; then
  echo "Creating service to exec NVMe Cache"
  cp -v /usr/bin/nvmecache.sh /tmpRoot/usr/bin/nvmecache.sh
  DEST="/tmpRoot/lib/systemd/system/nvmecache.service"
  echo "[Unit]"                                                               > ${DEST}
  echo "Description=Enable NVMe Cache"                                        >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/bin/nvmecache.sh"                                      >>${DEST}
  echo "ExecStop=/usr/bin/nvmecache.sh"                                       >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -p /tmpRoot/etc/systemd/system/multi-user.target.wants
  ln -sf /lib/systemd/system/nvmecache.service /tmpRoot/lib/systemd/system/multi-user.target.wants/nvmecache.service
fi
