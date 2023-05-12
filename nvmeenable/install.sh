#!/usr/bin/env ash

if [ "${1}" = "late" ]; then
  echo "Creating service to exec Enable NVMe"
  cp -v /usr/bin/nvmeenable.sh /tmpRoot/usr/bin/nvmeenable.sh
  DEST="/tmpRoot/lib/systemd/system/nvmeenable.service"
  echo "[Unit]"                                                                >${DEST}
  echo "Description=Enable NVMe as Storage"                                   >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Service]"                                                            >>${DEST}
  echo "Type=oneshot"                                                         >>${DEST}
  echo "RemainAfterExit=true"                                                 >>${DEST}
  echo "ExecStart=/usr/bin/nvmeenable.sh"                                     >>${DEST}
  echo "ExecStop=/usr/bin/nvmeenable.sh"                                      >>${DEST}
  echo                                                                        >>${DEST}
  echo "[Install]"                                                            >>${DEST}
  echo "WantedBy=multi-user.target"                                           >>${DEST}

  mkdir -p /tmpRoot/lib/systemd/system/multi-user.target.wants
  ln -sf /lib/systemd/system/nvmeenable.service /tmpRoot/lib/systemd/system/multi-user.target.wants/nvmeenable.service
fi
